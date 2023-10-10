#!/bin/bash
set -xe
PASSWORD="camarasuncosma2020"
OUTPUT_DIR="/home/admintaller/FOTOS"
RTSP_URL="rtsp://admin:${PASSWORD}@192.168.1.12:554/cam/realmonitor?channel=1&subtype=0"
mkdir -p $OUTPUT_DIR

NUM_PICTURES=5
INTERVAL_SECONDS=20

for ((i=1; i<=NUM_PICTURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$OUTPUT_DIR/snapshot_$TIMESTAMP.png"

    # Capture a single frame
    ffmpeg -i "$RTSP_URL" -vf "select=eq(pict_type\,I)" -vframes 1 -c:v libx264 -crf 0 "$OUTPUT_FILE"

    echo "Captured picture $i at $TIMESTAMP"

    if [ $i -lt $NUM_PICTURES ]; then
        sleep $INTERVAL_SECONDS
    fi
done
#
echo "PHOTOS TAKEN"
#
# Start capturing the RTSP feed and save it to a file
# ffmpeg -i "$RTSP_URL" -vf "select=eq(pict_type\,I)" -vframes 1 -c:v libx265 -crf 0 $OUTPUT_FILE
# # Store the PID of the ffmpeg process
# FFMPEG_PID=$!
# # Wait for some time (e.g., 30 seconds) to capture the video
# sleep 30

# # Kill the ffmpeg process
# kill "$FFMPEG_PID"
# # Upload the captured file to the remote server using scp
# scp "$OUTPUT_FILE" "$REMOTE_SERVER"
# # Clean up the local file (optional)
# rm "$OUTPUT_FILE"
# echo "RTSP capture and upload complete."
# cargo run --package client info --url "$RTSP_IP" --username admin --password $PASSWORD
# cargo run --package client mp4 --url "$RTSP_IP" --username admin --password $PASSWORD $OUTFILE
