#!/bin/shift

# start the main application or service
exec "ubuntu:latest"

# Infinite loop to keep container running for debug
while true; do
    sleep 60
done
