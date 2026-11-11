import subprocess
import sys

try:
    result = subprocess.check_output(
        ["nvidia-smi", "--query-gpu=power.draw", "--format=csv,noheader,nounits"],
        encoding="utf-8"
    ).strip()
    
    power_draw = float(result.split('\n')[0])
    
    if power_draw < 80:
        print(f"ALERT: Low power draw ({power_draw}W). Restarting...")
        sys.exit(1) 
        
    print(f"OK: Power draw is {power_draw}W")
    sys.exit(0)
    
except Exception as e:
    print(f"Error checking GPU: {e}")
    sys.exit(1)
