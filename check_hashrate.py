import subprocess
import sys

try:
    # Получаем потребление энергии видеокартой (в Ваттах)
    result = subprocess.check_output(
        ["nvidia-smi", "--query-gpu=power.draw", "--format=csv,noheader,nounits"],
        encoding="utf-8"
    ).strip()
    
    # Берем значение для первой карты (у нас она одна в контейнере)
    power_draw = float(result.split('\n')[0])
    
    # Порог для RTX 3060: если меньше 80 Вт — карту задушили
    if power_draw < 80:
        print(f"ALERT: Low power draw ({power_draw}W). Killing container for restart...")
        sys.exit(1) # Код 1 = ошибка, SaladCloud перезапустит контейнер
        
    print(f"OK: Power draw is {power_draw}W. Miner is healthy.")
    sys.exit(0)
    
except Exception as e:
    print(f"Error checking GPU: {e}")
    sys.exit(1)
