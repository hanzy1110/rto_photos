#!/bin/bash
set -xe
RTSP_IP="rtsp://@192.168.1.12:554/cam/realmonitor?channel=1&subtype=0"
PASSWORD="camarasuncosma2020"
OUTFILE="/home/admintaller/vigilancia.mp4"
cargo run --package client info --url "$RTSP_IP" --username admin --password $PASSWORD $OUTFILE
cargo run --package client mp4 --url "$RTSP_IP" --username admin --password $PASSWORD $OUTFILE
