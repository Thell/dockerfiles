#!/bin/bash

DIR="$(realpath "$0")"
DIR="$(dirname $DIR)"

faketime=$(ls -ort --time-style=+"%Y-%m-%d %T" $DIR/../lib/eureqa/ | cut -d' ' -f5-6 | tail -1)

pulseserver=$(pax11publish | grep Server | cut -d: -f3)
utmpdir=${HOME}/.local/tmp
xtmp=/tmp/.X11-unix

xhost local:docker
docker run -d \
  --net none \
  --device /dev/dri \
 	--device /dev/snd \
 	-v $pulseserver:$pulseserver \
	-e DISPLAY=unix$DISPLAY \
	-v $xtmp:$xtmp \
	-v $utmpdir:/home/nouser/.local/tmp \
  -e FAKETIME="@${faketime}" \
  eureqa:latest "$@"
