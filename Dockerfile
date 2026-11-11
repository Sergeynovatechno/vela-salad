FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Принудительно фиксируем стандартные надежные зеркала Ubuntu
RUN rm -rf /etc/apt/sources.list.d/* && \
    echo "deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# 2. Устанавливаем пакеты с таймаутами и повторами
RUN apt-get update -o Acquire::Retries=5 && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    wget \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

# 3. Скачиваем самую актуальную версию майнера FreeForGemVela (0.4.5)
RUN wget https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.5/ffgv-hive-0.4.5.tar.gz && \
    tar -xvf ffgv-hive-0.4.5.tar.gz && \
    cd ffgv-hive && \
    chmod +x ffgv

# 4. Копируем скрипты запуска и стража ваттметра
COPY entrypoint.sh /entrypoint.sh
COPY check_hashrate.py /check_hashrate.py

# 5. Исправляем окончания строк и выдаем права на запуск
RUN sed -i 's/\r$//' /entrypoint.sh && \
    sed -i 's/\r$//' /check_hashrate.py && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
