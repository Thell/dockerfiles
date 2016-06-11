#!/bin/bash

# GCC Explorer

utmpdir=${HOME}/.local/tmp

docker run -d \
	-v /etc/machine-id:/etc/machine-id \
	-v /etc/localtime:/etc/localtime:ro \
	-v $utmpdir:$utmpdir \
	-p 10240:10240 \
	gcc-explorer
