#!/bin/bash

# Script to automate sys-call collection and malware execution

# Set variables
LOG_FILE="/home/crsuser/syscalls_experiment.log"
MALWARE_PATH="/home/crsuser/theZoo/malware/Binaries/Linux.Mirai.B/mirai_executable"
MALWARE_NAME="$(basename $MALWARE_PATH)"

# Function to start sys-call monitoring
start_monitoring() {
    echo "Starting sys-call monitoring and logging to $LOG_FILE"
    sudo ./syscount_all.bt > $LOG_FILE &
    MONITOR_PID=$!
    echo "Monitoring started with PID $MONITOR_PID"
}

# Function to run malware
run_malware() {
    echo "Starting malware execution from $MALWARE_PATH"
    chmod +x $MALWARE_PATH
    nohup $MALWARE_PATH > /dev/null 2>&1 &

    # Wait a moment to ensure the malware starts
    sleep 2

    # Capture the PID of the malware process
    MALWARE_PID=$(pgrep -f "$MALWARE_NAME")
    if [ -z "$MALWARE_PID" ]; then
        echo "Error: Malware PID could not be found."
    else
        echo "Malware running with PID $MALWARE_PID"
    fi
}

# Function to stop monitoring
stop_monitoring() {
    echo "Stopping sys-call monitoring"
    kill $MONITOR_PID
    wait $MONITOR_PID 2>/dev/null
    echo "Monitoring stopped"
}

# Main execution flow
start_monitoring

# Sleep for 1.5 hours to collect benign data (5400 seconds)
echo "Collecting benign data for 1.5 hours..."
sleep 5400

# Run malware and continue monitoring
run_malware

# Collect data for 3 more hours (10800 seconds)
echo "Collecting data during malware execution for 3 hours..."
sleep 10800

# Stop monitoring after the experiment
stop_monitoring

# Print completion message
echo "Experiment completed. Sys-call data saved to $LOG_FILE"
