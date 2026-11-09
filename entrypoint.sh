#!/bin/bash
cd /root/ffgv-hive
./ffgv --pool stratum+ssl://vela.suprnova.cc:7604 \
       --user vela1qhwm75w00j83qfyqvapgn84jv485gsyqtf4yw35.rig1 \
       --model sd-turbo-int.poisd \
       --mode balance
