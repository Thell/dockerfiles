#!/bin/sh

# apt-fast aria2 downloads progress output
# trigger using --on-download-complete callback.

# Provide bytesNeeded in the parent environment...
#	 apturis=$(apt-get -qq --print-uris "$@")
#	 export DLLISTBYTES=$( echo "$apturis"| awk -F " " '{bytes+=$3} END{print bytes}' )

aria2_rpc () {
	http --ignore-stdin localhost:6800/jsonrpc id=apt-fast method=aria2.$1
}

export $( aria2_rpc getGlobalStat | jq -r '.result|to_entries[]|join("=")' )

bytesDownloaded=$( du -bcs $(dirname -- $3)/* | tail -1 | cut -f1 )
bytesNeeded=$DLLISTBYTES
numUris=$(( numActive + numStopped + numWaiting ))
percentBytes=$(( bytesDownloaded * 100 / bytesNeeded ))
percentUris=$(( numStopped * 100 / numUris ))

bytesDownloaded_siB=$( numfmt --to si --suffix B $bytesDownloaded )
bytesDownloaded_ieciB=$( numfmt --to iec-i --suffix B --round nearest $bytesDownloaded )
bytesNeeded_ieciB=$( numfmt --to iec-i --suffix B --round nearest $bytesNeeded )
downloadSpeed_ieciBs=$( numfmt --to iec-i --suffix B/s $downloadSpeed )

aria2PID=$(pgrep -f '^aria2c*' --oldest)
timeElapsed=$(ps -p $aria2PID -o etime= | tr -d " ")

eval $( apt-config shell STATUS_FD APT::Status-Fd )

# Common status to either stderr or status-fd
status_message=$( \
	printf "[ %s / %s @ %s ][ W: %d A: %d S: %d / %d (%d%%) ]" \
		"$bytesDownloaded_ieciB" \
		"$bytesNeeded_ieciB" \
		"$downloadSpeed_ieciBs" \
		"$numWaiting" \
		"$numActive" \
		"$numStopped" \
		"$numUris" \
		"$percentUris"
	)

if [ "$STATUS_FD" > "0" ]; then

	# eval "exec 1>&${STATUS_FD}"
	printf "%s:%s:%s:Retrieved %s\n" \
	  "dlstatus" \
	  "$numStopped" \
	  "$percentBytes" \
		"$status_message" >&$STATUS_FD

else

	[ "$numStopped" = "1" ] && printf "\r$(tput cuu1)"
	printf "\r %s %3s%% %s$(tput el)" \
		"$timeElapsed" \
		"$percentBytes" \
		"$status_message" >&2

fi

# Sometimes the last n uris will complete between when aria2 emits
# the trigger callback and when the stats are read, so this lock
# seems to be enough to eliminate multiple "Fetched" messages, but
# the status line update should still be sent.

exec 9>/dev/null
if [ "$numStopped" = "$numUris" ] && flock -w 0 -x 9; then
	# Queue is exhausted.
	
	[ "$STATUS_FD" > "0" ] || printf "\r$(tput el)$(tput cuu1) "
	printf "Fetched %s [%s] in %s (%s) from %d packages.$(tput el)\n" \
	  "$bytesDownloaded_siB" \
		"$bytesDownloaded_ieciB" \
		"$timeElapsed" \
		"$downloadSpeed_ieciBs" \
		"$numUris"

	aria2_rpc shutdown > /dev/null
	wait "$aria2PID"
fi
