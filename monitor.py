f"🎯 Доля в раунде: {stats['my_round_share']*100:.2f}%\n"
        f"💎 Награда за блок: {stats['my_round_credit']:.4f} VELA\n\n"
        f"🌐 *Пул и Сеть:*\n"
        f"Сложность сети: {stats['network_diff']:.2f} M\n"
        f"Хешрейт пула: {stats['pool_hashrate']:.1f} inf/s\n"
        f"Хешрейт сети: {stats['network_hashrate']:.0f} inf/s\n"
        f"Воркеров на пуле: {stats['pool_workers']}\n\n"
    )
    
    now = datetime.now(MINSK_TZ)
    if now.hour == 0: # Раз в сутки, в полночь по Минску
        message += analyze_best_hours(history)

    send_telegram_message(message)
    print("Сообщение отправлено!")

if name == "main":
    main()
