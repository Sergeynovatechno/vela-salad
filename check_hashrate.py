import subprocess
import sys

try:
    # Спрашиваем у видеокарты текущее потребление энергии (в Ваттах)
    result = subprocess.check_output(
        ["nvidia-smi", "--query-gpu=power.draw", "--format=csv,noheader,nounits"],
        encoding="utf-8"
    ).strip()
    
    # Берем первую карту
    power_draw = float(result.split('\n')[0])
    
    # Если потребление меньше 150 Ватт (значит карту задушили) или 0
    if power_draw < 150:
        print(f"ALERT: Low power draw ({power_draw}W). Restarting...")
        sys.exit(1) # Ошибка -> SaladCloud перезапускает контейнер
        
    print(f"OK: Power draw is {power_draw}W")
    sys.exit(0)
    
except Exception as e:
    print(f"Error checking GPU: {e}")
    sys.exit(1)
