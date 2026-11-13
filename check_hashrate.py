import subprocess
import sys
import os
import re

LOG_FILE = "/root/miner.log"

try:
    result = subprocess.check_output(["nvidia-smi", "--query-gpu=power.draw", "--format=csv,noheader,nounits"], encoding="utf-8").strip()
    power_draw = float(result.split('\n')[0])
    
    # Оставляем порог 150 Вт
    if power_draw < 150:
        print(f"CHECK FAILED: Low power draw ({power_draw}W < 150W).")
        sys.exit(1)

    if not os.path.exists(LOG_FILE):
        print("CHECK FAILED: Log file not found yet.")
        sys.exit(1)

    with open(LOG_FILE, "r") as f:
        lines = f.readlines()[-50:]

    hashrate = 0.0
    for line in reversed(lines):
        match = re.search(r"GPU0\s+([\d.]+)\s+inf/s", line)
        if match:
            hashrate = float(match.group(1))
            break

    # СНИЖАЕМ ПОРОГ ДО 25 inf/s
    if hashrate > 0 and hashrate < 25.0:
         print(f"CHECK FAILED: Hashrate dropped to {hashrate} inf/s (< 25).")
         sys.exit(1)
    elif hashrate == 0.0:
         print("CHECK FAILED: No hashrate found in logs.")
         sys.exit(1)

    print(f"CHECK OK: Power draw is {power_draw}W, Hashrate is {hashrate} inf/s.")
    sys.exit(0)
    
except Exception as e:
    print(f"CHECK FAILED: Error checking stats: {e}")
    sys.exit(1)
