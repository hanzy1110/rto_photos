#!/bin/bash
set -xe
source .env.prod

PASSWORD="camarasuncosma2020"
OUTPUT_DIR="/home/admintaller/FOTOS"
RTSP_URL="rtsp://admin:${PASSWORD}@192.168.1.12:554/cam/realmonitor?channel=1&subtype=0"
mkdir -p $OUTPUT_DIR

NUM_PICTURES=5
INTERVAL_SECONDS=20

S3_DESTINATION="s3://${S3_BUCKET}/rto-nqn-files"

aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set region "$AWS_DEFAULT_REGION"

for ((i = 1; i <= NUM_PICTURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$OUTPUT_DIR/snapshot_$TIMESTAMP.raw"
    OUTPUT_FILE_JPG="$OUTPUT_DIR/snapshot_$TIMESTAMP.jpg"

    # Capture a single frame
    ffmpeg -i "$RTSP_URL" -vf "select=eq(pict_type\,I)" -vframes 1 -c:v libx264 -crf 0 "$OUTPUT_FILE"
    ffmpef -i $OUTPUT_FILE $$OUTPUT_FILE_JPG

    echo "Captured picture $i at $TIMESTAMP"

    if [ $? -eq 0 ]; then
        echo "File uploaded to S3 successfully."
        rm $OUTPUT_FILE $OUTPUT_FILE_JPG
    else
        echo "File upload to S3 failed."
    fi

    if [ $i -lt $NUM_PICTURES ]; then
        sleep $INTERVAL_SECONDS
    fi
done

gzip -c "$OUPUT_DIR" >"FOTOS_${TIMESTAMP}.zip"
aws s3 cp "FOTOS_${TIMESTAMP}.zip" "$S3_DESTINATION"
