#!/bin/bash
set -xe
PASSWORD="camarasuncosma2020"
OUTFILE="/home/admintaller/vigilancia.mp4"

RTSP_URL="rtsp://admin:${PASSWORD}@192.168.1.12:554/cam/realmonitor?channel=1&subtype=0"
# Start capturing the RTSP feed and save it to a file
ffmpeg -i "$RTSP_URL" -codec copy "$OUTPUT_FILE" &
# Store the PID of the ffmpeg process
FFMPEG_PID=$!
# Wait for some time (e.g., 30 seconds) to capture the video
sleep 30

# Kill the ffmpeg process
kill "$FFMPEG_PID"
# Upload the captured file to the remote server using scp
scp "$OUTPUT_FILE" "$REMOTE_SERVER"
# Clean up the local file (optional)
rm "$OUTPUT_FILE"
echo "RTSP capture and upload complete."
# cargo run --package client info --url "$RTSP_IP" --username admin --password $PASSWORD
# cargo run --package client mp4 --url "$RTSP_IP" --username admin --password $PASSWORD $OUTFILE
