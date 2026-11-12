#!/bin/bash
cd /root/ffgv-hive

./ffgv --pool stratum+ssl://vela.suprnova.cc:7604 \
       --user vela1qhwm75w00j83qfyqvapgn84jv485gsyqtf4yw35.rig-$HOSTNAME \
       --model sd-turbo-int.poisd \
       --mode speed \
       --lanes 1 \
       --batch 8 &
MINER_PID=$!

# Даем майнеру 60 секунд на прогрев и выход на рабочую мощность
sleep 60

while true; do
    sleep 30
    python3 /check_hashrate.py
    if [ $? -ne 0 ]; then
        kill -TERM $MINER_PID
        exit 1
    fi
done
