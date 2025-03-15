#!/bin/bash
mkdir -p /home/logging/
curl http://$LOGGING_SERVER_IP:8000/scripts.tar.gz -o /home/logging/scripts.tar.gz
