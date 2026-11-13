import os
import json
import requests
from datetime import datetime, timezone, timedelta

# --- НАСТРОЙКИ ---
BOT_TOKEN = os.environ.get("BOT_TOKEN")
CHAT_ID = os.environ.get("CHAT_ID")
WALLET = "vela1qhwm75w00j83qfyqvapgn84jv485gsyqtf4yw35"
POOL_URL = "https://vela.suprnova.cc"
HISTORY_FILE = "history.json"

MINSK_TZ = timezone(timedelta(hours=3))

def send_telegram_message(text):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"
    payload = {"chat_id": CHAT_ID, "text": text, "parse_mode": "Markdown"}
    requests.post(url, json=payload)

def get_stats():
    try:
        # 1. Общая статистика пула и сети
        pool_resp = requests.get(f"{POOL_URL}/api/pools/vela", timeout=10).json()
        pool_stats = pool_resp.get("poolStats", {})
        network_stats = pool_resp.get("networkStats", {})

        # 2. Статистика нашего кошелька
        miner_resp = requests.get(f"{POOL_URL}/api/pools/vela/miners/{WALLET}", timeout=10).json()
        
        # 3. Доля в текущем раунде
        round_resp = requests.get(f"{POOL_URL}/api/pools/vela/miners/{WALLET}/round", timeout=10).json()

        return {
            "my_hashrate": miner_resp.get("hashrate", 0),
            "my_workers": miner_resp.get("workers", 0),
            "my_balance": miner_resp.get("balance", 0),
            "my_round_share": round_resp.get("share", 0),
            "my_round_credit": round_resp.get("estimatedCredit", 0),
            "pool_hashrate": pool_stats.get("poolHashrate", 0),
            "pool_workers": pool_stats.get("connectedWorkers", 0),
            # ИСПРАВЛЕНО: теперь используем ключ "difficulty"
            "network_diff": network_stats.get("difficulty", 0) / 1_000_000,
            "network_hashrate": network_stats.get("networkHashrate", 0),
        }
    except Exception as e:
        print(f"Ошибка API: {e}")
        return None

def update_history(stats):
    history = []
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "r") as f:
            history = json.load(f)
    
    now = datetime.now(MINSK_TZ)
    stats["timestamp"] = now.isoformat()
    stats["hour"] = now.hour
    stats["day"] = now.strftime("%A")
    
    history.append(stats)
    history = history[-168:] # Храним 7 дней
    
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=4)
    return history

def analyze_best_hours(history):
    if len(history) < 24:
        return "📉 Пока недостаточно данных для анализа (нужно 24 часа)."
    
    hourly_stats = {}
    for record in history:
        h = record["hour"]
        if h not in hourly_stats:
            hourly_stats[h] = []
        hourly_stats[h].append(record["network_diff"])
    
    avg_hourly = {h: sum(diffs)/len(diffs) for h, diffs in hourly_stats.items()}
    best_hours = sorted(avg_hourly.items(), key=lambda x: x[1])[:3]
    
    text = "🕒 *Лучшие часы для майнинга (по Минску):*\n"
    for hour, diff in best_hours:
        text += f"▪️ {hour:02d}:00 — средняя сложность {diff:.2f} M\n"
    return text

def main():
    stats = get_stats()
    if not stats:
        send_telegram_message("❌ Ошибка получения данных с пула.")
        return

    history = update_history(stats)
    diff = stats["network_diff"]
    
    # Проверка статуса
    if diff < 3.0:
        status = "🟢 *ЗОЛОТОЕ ОКНО!* Сложность низкая, самое время майнить."
    elif diff > 4.5:
        status = "🔴 *ДНЕВНОЙ ПИК!* Сложность высокая, майнинг невыгоден."
    else:
        status = "🟡 *Средняя сложность.* Работаем в обычном режиме."

    message = (
        f"{status}\n\n"
        f"👤 *Твой майнер:*\n"
        f"⛏️ Хешрейт: {stats['my_hashrate']:.1f} inf/s\n"
        f"🖥️ Воркеров: {stats['my_workers']}\n"
        f"💰 Баланс: {stats['my_balance']:.4f} VELA\n"
        f"🎯 Доля в раунде: {stats['my_round_share']*100:.2f}%\n"
        f"💎 Награда за блок: {stats['my_round_credit']:.4f} VELA\n\n"
        f"🌐 *Пул и Сеть:*\n"
        f"Сложность сети: {stats['network_diff']:.2f} M\n"
        f"Хешрейт пула: {stats['pool_hashrate']:.1f} inf/s\n"
        f"Хешрейт сети: {stats['network_hashrate']:.0f} inf/s\n"
        f"Воркеров на пуле: {stats['pool_workers']}\n\n"
    )
    
    now = datetime.now(MINSK_TZ)
    if now.hour == 0: # Раз в сутки в полночь
        message += analyze_best_hours(history)

    send_telegram_message(message)
    print("Сообщение отправлено!")

if __name__ == "__main__":
    main()
