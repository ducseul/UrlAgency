#!/bin/bash

PID_FILE="PID.txt"
LOG_FILE="agency.log"
SCRIPT="_agency.sh"

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [kill|start|status]"
    exit 1
fi

if [ "$1" == "kill" ]; then
    if [ -f "$PID_FILE" ]; then
        echo "Killing process with PID $(cat $PID_FILE)"
        kill -9 $(cat "$PID_FILE")
        rm "$PID_FILE"
    else
        echo "Process is not running (PID file not found)."
    fi
elif [ "$1" == "start" ]; then
    if [ -f "$PID_FILE" ]; then
        echo "Process is already running with PID $(cat $PID_FILE)"
    else
        echo "Starting process..."
        nohup "./$SCRIPT" >> "$LOG_FILE" 2>&1 & echo $! > "$PID_FILE"
        echo "Process started with PID $(cat $PID_FILE)"
    fi
elif [ "$1" == "status" ]; then
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null; then
            echo "Process is running with PID $PID"
        else
            echo "Process is not running (PID file exists but process not found)."
        fi
    else
        echo "Process is not running (PID file not found)."
    fi
else
    echo "Invalid command. Usage: $0 [kill|start|status]"
    exit 1
fi