#!/bin/bash

# Home
DIR=/var/log/journal

# Logging user name
NAME=Logging

useradd -m -d "$DIR" -p "password" -k /dev/null -s /bin/sh

