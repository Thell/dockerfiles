#!/bin/bash

# cpp to assembly

utmpdir=${HOME}/.local/tmp

docker run --rm -it \
	-v /etc/machine-id:/etc/machine-id \
	-v /etc/localtime:/etc/localtime:ro \
	-v $utmpdir:$utmpdir \
	-p 8080:8080 \
	cpp-to-assembly "$@"
