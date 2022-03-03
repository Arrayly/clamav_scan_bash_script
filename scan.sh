#! /bin/bash

# Unique webhook ID for Slack
SLACK_TOKEN=XYXYXYXYXYXYXYXYXYXYXYXYX

TIMESTAMP=`date +"%d_%b_%Y_%H%M"`

# Where to store infected files
QUARANTINE_DIR=/home/eis/clamav-quarantine

# Where to store scan result logs
LOG_DIR=/home/eis/virus-scan-reports

LOG="$LOG_DIR/virus-scan-report-$TIMESTAMP.txt"

notify(){
	MESSAGE=`cat $LOG`
	curl -X POST -H 'Content-type: application/json' --data '{"text":"Virus scan results: '"$MESSAGE"'"}' https://hooks.slack.com/services/$SLACK_TOKEN
}

# Clear freshclam logs
rm -rf /var/log/clamav/freshclam.log

# Update anti-virus files
freshclam

# Run scan
if clamscan -r -i /home/eis --move=$QUARANTINE_DIR --exclude=$QUARANTINE_DIR | grep FOUND >> "$LOG"; then notify; else echo "ALL CLEAN" >> "$LOG"; fi

# Store only up to 14 logs
find "$LOG_DIR/." -mtime +14 -exec rm {} \;
