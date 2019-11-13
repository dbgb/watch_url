#!/bin/bash

WATCH_URL="https://url.goes.here"
WATCH_FILTER="grep_filter_goes_here"
USER_AGENT="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:70.0) Gecko/20100101 Firefox/70.0"

WAIT_OFFSET=20 # seconds

LOG_NAME=$(basename $0)
LOG_NAME=${LOG_NAME%%.sh}.log
LOG_MAX_SIZE=50000 # 1000kB = 1MB

# Auto-delete log file at max size
[[ $(du -k "$LOG_NAME" | cut -f 1) -ge $LOG_MAX_SIZE ]] && rm "$LOG_NAME"

while true; do
  [[ $1 == "-c" || $1 == "--clear" ]] && clear;

  echo
  curl -s "$WATCH_URL" -A "$USER_AGENT" | grep -i "$WATCH_FILTER"
  echo

  WAIT_INTERVAL="$(((RANDOM % 10) + 1 + $WAIT_OFFSET))" # 1->10s + offset
  echo \[$(date "+%Y-%m-%d %H:%M:%S")\] Waiting "$WAIT_INTERVAL"s ...
  sleep "$WAIT_INTERVAL"s

done | tee -a "$LOG_NAME"

