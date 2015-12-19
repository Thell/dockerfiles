#!/bin/bash

# Cursor-postioning and output control...
: <<'thoughts'

Essentially all this does is capture lines from stdout, stderr, statusfd and a timer
and prepends the source stream name to the line then forwards the modified lines
to a FD (modall) which is read by the reporter.

Keep the output control under control using FD streams...


     (1>)stdout   -> (4<1)modout(1> modall 2>&5)                        stderr and unknown
    /                                          \                      / 
cmd--(2>)stderr   -> (5<2)moderr(1>&2 modall) --> (7)modall -> writer - stdout (typical progress lines)
    \                                          /                      \ 
     (3>)statusfd -> (6<3)modstl(1> modall 2>&5)                    	  [time] [percent] status message

thoughts

###########################################################

NAME="$(basename $0)"
FDDIR=/dev/shm/${NAME}/fifo
APTSTATUS=/etc/apt/apt.conf.d/90status-fd
stdstl=3

cleanup () {
	: >$guard
	eval "exec ${stdstl}<&-"
	eval "exec ${stdtmr}<&-"
	rm -f $guard
	sleep 1 # wait for the timer to exit
	rm -rf "$FDDIR"
	rm -f "$APTSTATUS"
	tput ed
}

init () {

	mkdir -p "$FDDIR"

	# Setup and guard FIFOs (keep "guard" first).
	for i in guard modall moderr modout modstl modtmr; do
		tmp=${FDDIR}/${i}
	  eval "export ${i}=${tmp}"
	  eval "mkfifo ${tmp}"
	  if [ "$i" != "guard" ]; then
	  	eval ": >${tmp} < ${guard} &"
	  fi
	done

	# Startup listeners to add stream tokens.
  for i in filter fmtstdout fmtstderr fmtstdstl fmtstdtmr timer; do
    eval "${i} &"
  done

	echo "APT::Status-Fd \"${stdstl}\";" > "${APTSTATUS}"
}

filter () {
	elapsed="$(ps -p $$ -o etime= | tr -d ' ')"
  percentage=0
  progress="Working ..."
  status="[Working]"

  tput hpa 0

	exec <$modall
	while read line; do

		case $line in
			stdout:*)
				line="${line#stdout:}"
				tmp=$(printf "%s" "$line" |  tr -dc "[:graph:]")
				[ "$tmp" = "" ] || progress=$line
				;;
			stderr:*)
				keep="${line#stderr:}"
				;;
			stdstl:*)
				status="${line#stdstl:}"
				percentage=$(echo "$status" | cut -d: -f3)
			  status=$(echo "$status" | cut -d: -f4-)
				;;
			stdtmr:*)
				elapsed="${line#stdtmr:}"
				;;
			*)
				keep="UNCAPTURED:: $line"
				;;
		esac

		[ "$keep" = "" ] || printf "%s$(tput el)\n" "$keep" >&2

		tput ed

		printf "%s\n" "$progress"
	  printf "%s [%.*f%%] %s\n" "$elapsed" 0 $percentage "$status"

	  tput cuu 2

	  # Because dpkg seems to think it is ok to put status info to stderr.
	  if [ "${keep#*100%*}" != "$keep" ]; then
	  	tput cuu1
	  fi
	  keep=""

  done
}

fmtstdout () {
	exec <$modout
	exec 1>$modall
	exec 2>$moderr
	while read line; do
	  printf "stdout:%s\n" "$line"
	done
}

fmtstderr () {
	exec <$moderr
	exec 1>$modall
	while read line; do
	  printf "stderr:%s\n" "$line"
	done
}

fmtstdstl () {
	exec <$modstl
	exec 1>$modall
	exec 2>$moderr
	while read line; do
	 if [ "${line#*status:}" = "$line" ]; then
	   printf "%s\n" "$line" >$modout
	 else
	   printf "stdstl:%s\n" "$line"
	 fi 
	done
}

fmtstdtmr () {
	exec <$modtmr
	exec 1>$modall
	exec 2>$moderr
	RE='^([[:digit:]]{2}[-:]){1,3}[[:digit:]]{2}'
	while read line; do
		line=${line#[[:space:]]*}
		if printf "%s" "$line" | grep -qE "${RE}"; then
	  	printf "stdtmr:%s\n" "$line"
		else
			printf "%s\n" "$line" > "$modout"
	  fi
	done
}

timer () {
	exec 1>$modtmr
	while [ -e $guard ]; do
		sleep 1
		printf "%s\n" "$(ps -p $$ -o etime=)"
	done
}

trap 'cleanup' EXIT

init
eval "$@" 1>${modout} 2>${moderr} 3>${modstl}
