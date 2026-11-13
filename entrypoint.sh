#!/bin/bash
cd /root/ffgv-hive

./ffgv --pool stratum+ssl://vela.suprnova.cc:7604 \
       --user vela1qhwm75w00j83qfyqvapgn84jv485gsyqtf4yw35.salad-rig \
       --model sd-turbo-int.poisd \
       --mode speed \
       --lanes 1 \
       --batch 10 > /root/miner.log 2>&1 &
MINER_PID=$!

sleep 60

FAIL_COUNT=0
MAX_FAILS=3

while true; do
    sleep 30
    python3 /check_hashrate.py
    RESULT=$?
    
    if [ $RESULT -ne 0 ]; then
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "WARNING: Плохие показатели. Страйк $FAIL_COUNT из $MAX_FAILS."
        
        if [ $FAIL_COUNT -ge $MAX_FAILS ]; then
            echo "ALERT: Показатели плохие 90 секунд подряд! Убиваем контейнер..."
            kill -TERM $MINER_PID
            exit 1
        fi
    else
        FAIL_COUNT=0
    fi
done
