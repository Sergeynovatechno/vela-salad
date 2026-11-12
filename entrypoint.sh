#!/bin/bash
cd /root/ffgv-hive

# Запускаем майнер в фоне и пишем логи в файл. 
# ВНИМАНИЕ: Теперь имя воркера всегда "salad-rig" (вместо $HOSTNAME)
./ffgv --pool stratum+ssl://vela.suprnova.cc:7604 \
       --user vela1qhwm75w00j83qfyqvapgn84jv485gsyqtf4yw35.salad-rig \
       --model sd-turbo-int.poisd \
       --mode speed \
       --lanes 1 \
       --batch 8 > /root/miner.log 2>&1 &
MINER_PID=$!

# Ждем 60 секунд, чтобы майнер скачал модель и вышел на рабочую мощность
sleep 60

# Переменная для подсчета ошибок подряд
FAIL_COUNT=0
MAX_FAILS=3 # 3 замера по 30 секунд = 90 секунд

while true; do
    sleep 30
    
    # Запускаем проверку
    python3 /check_hashrate.py
    RESULT=$?
    
    if [ $RESULT -ne 0 ]; then
        # Если проверка не пройдена, увеличиваем счетчик
        FAIL_COUNT=$((FAIL_COUNT + 1))
        echo "WARNING: Плохие показатели. Страйк $FAIL_COUNT из $MAX_FAILS."
        
        if [ $FAIL_COUNT -ge $MAX_FAILS ]; then
            echo "ALERT: Показатели плохие 90 секунд подряд! Убиваем контейнер для смены карты..."
            kill -TERM $MINER_PID
            exit 1
        fi
    else
        # Если проверка пройдена, сбрасываем счетчик в ноль
        if [ $FAIL_COUNT -ne 0 ]; then
            echo "INFO: Показатели восстановились. Счетчик страйков сброшен."
        fi
        FAIL_COUNT=0
    fi
done
