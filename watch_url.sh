#!/bin/bash

usage(){
  echo "$(basename $0) <options>"
  echo -e "\nOptions:\n"
  echo "-u (The url to be parsed)"
  echo "-f (Optional: Case insensitive grep pattern)"
  echo "-U (Optional: User agent string)"
  echo "-c (Optional: Clear terminal on each watch iteration)"
  echo "-C (Optional: Clean script log, then exit)"
  echo "-h (Optional: Display usage information, then exit)"
}


# Default values
USER_AGENT="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:70.0) Gecko/20100101 Firefox/70.0"

WAIT_OFFSET=20 # seconds

LOG_NAME=$(basename $0)
LOG_NAME=${LOG_NAME%%.sh}.log
LOG_MAX_SIZE=50000 # 1000kB = 1MB

while getopts ":hCcu:U:f:" OPT; do
  case $OPT in
    h)
      usage
      exit 1
      ;;
    C)
      rm -iv "$LOG_NAME"
      exit 1
      ;;
    c)
      CLEAR_TERM=true
      ;;
    u)
      WATCH_URL="$OPTARG"
      ;;
    U)
      USER_AGENT="$OPTARG"
      ;;
    f)
      WATCH_FILTER="$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    \?)
      echo -e "Invalid option: -$OPTARG\n" >&2
      usage
      exit 1
      ;;
  esac
done

# Auto-delete log file at max size
[[ $(du -k "$LOG_NAME" | cut -f 1) -ge $LOG_MAX_SIZE ]] && rm "$LOG_NAME"

while true; do
  [[ $CLEAR_TERM ]] && clear;

  echo
  curl -s "$WATCH_URL" -A "$USER_AGENT" | grep -i "$WATCH_FILTER"
  echo

  WAIT_INTERVAL="$(((RANDOM % 10) + 1 + $WAIT_OFFSET))" # 1->10s + offset
  echo \[$(date "+%Y-%m-%d %H:%M:%S")\] Waiting "$WAIT_INTERVAL"s ...
  sleep "$WAIT_INTERVAL"s

done | tee -a "$LOG_NAME"

