#!/bin/bash

cleanup() {
	echo "Killing pixiewps processes..."
	sudo pkill -KILL -f pixiewps || true

    	echo "Killing ose.py processes..."
    	sudo pkill -KILL -f ose.py || true

    	echo "Killing main.py Python script..."
    	pkill -KILL -f main.py || true

    	echo "Killing any remaining specific python3 processes..."
    	pkill -KILL -f ".scripts/pixie-all/venv/bin/python" || true

    	echo "Killing remaining processes in current process group..."
    	kill -KILL 0 || true

    	echo "Exiting..."
}

trap cleanup INT TERM

echo "The script can be stopped using ctrl+c"

.scripts/pixie-all/venv/bin/python .scripts/pixie-all/main.py

