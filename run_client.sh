#!/bin/bash
set -xe
source /home/admintaller/git/rto_photos/.env.prod

CAM_IP=$1

PASSWORD="camarasuncosma2020"
OUTPUT_DIR="/home/admintaller/FOTOS_${CAM_IP}"
RTSP_URL="rtsp://admin:${PASSWORD}@${CAM_IP}:554/cam/realmonitor?channel=1&subtype=0"
mkdir -p "$OUTPUT_DIR"

NUM_PICTURES=5
INTERVAL_SECONDS=30

S3_DESTINATION="s3://rto-nqn-files/FOTOS_TALLER"

# /usr/bin/local/aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
# /usr/bin/local/aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
# /usr/bin/local/aws configure set region "us-east-1"

for ((i = 1; i <= NUM_PICTURES; i++)); do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    OUTPUT_FILE="$OUTPUT_DIR/snapshot_$TIMESTAMP.png"
    OUTPUT_FILE_JPG="$OUTPUT_DIR/snapshot_$TIMESTAMP.jpg"
    # Capture a single frame
    ffmpeg -i "$RTSP_URL" -vf "select=eq(pict_type\,I)" -vframes 1 -c:v libx264 -crf 0 "$OUTPUT_FILE" >ffmpeg.log 2>&1

    if [ $? -eq 0 ]; then
        echo "CONVERSION"
        ffmpeg -i "$OUTPUT_FILE" "$OUTPUT_FILE_JPG"
        echo "Captured picture $i at $TIMESTAMP"
    fi

    if [ $i -lt $NUM_PICTURES ]; then
        sleep $INTERVAL_SECONDS
    fi
done

TAR_OUTPUT="${CAM_IP}_FOTOS_${TIMESTAMP}.tar.gz"
tar -czvf "$TAR_OUTPUT" "$OUTPUT_DIR"
/usr/local/bin/aws s3 cp "$TAR_OUTPUT" "$S3_DESTINATION/${TAR_OUTPUT}"

if [ $? -eq 0 ]; then
    echo "File uploaded to S3 successfully."
else
    echo "File upload to S3 failed."
fi

rm -rf ./*.tar.gz
rm -rf $OUTPUT_DIR
