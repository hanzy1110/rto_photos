#!/bin/bash
set -xe
source .env.prod

PASSWORD="camarasuncosma2020"
OUTPUT_DIR="/home/admintaller/FOTOS"
RTSP_URL="rtsp://admin:${PASSWORD}@192.168.1.12:554/cam/realmonitor?channel=1&subtype=0"
mkdir -p $OUTPUT_DIR

NUM_PICTURES=5
INTERVAL_SECONDS=20

S3_DESTINATION="s3://rto-nqn-files/FOTOS_TALLER"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "us-east-1"

for ((i = 1; i <= NUM_PICTURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$OUTPUT_DIR/snapshot_$TIMESTAMP.png"
    OUTPUT_FILE_JPG="$OUTPUT_DIR/snapshot_$TIMESTAMP.jpg"

    # Capture a single frame
    ffmpeg -i "$RTSP_URL" -vf "select=eq(pict_type\,I)" -vframes 1 -c:v libx264 -crf 0 "$OUTPUT_FILE"
    ffmpeg -i "$OUTPUT_FILE" "$OUTPUT_FILE_JPG"

    echo "Captured picture $i at $TIMESTAMP"

    # if [ $? -eq 0 ]; then
    #     echo "File uploaded to S3 successfully."
    # else
    #     echo "File upload to S3 failed."
    # fi

    if [ $i -lt $NUM_PICTURES ]; then
        sleep $INTERVAL_SECONDS
    fi
done
tar -czvf "FOTOS_${TIMESTAMP}.tar.gz" $OUTPUT_DIR
aws s3 cp "FOTOS_${TIMESTAMP}.zip" "$S3_DESTINATION"

rm -rf $OUTPUT_DIR
