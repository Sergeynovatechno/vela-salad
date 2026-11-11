FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Фиксим DNS (частая проблема на серверах GitHub)
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

# 2. Убираем старые репозитории NVIDIA, чтобы apt-get не спотыкался
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list

# 3. Ставим пакеты с встроенными повторными попытками (Retries)
RUN apt-get update -o Acquire::Retries=5 && \
    apt-get install -y --no-install-recommends \
    wget \
    python3 \
    python3-pip \
    git \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

# 4. Скачиваем сам майнер
RUN wget https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.5/ffgv-hive-0.4.5.tar.gz && \
    tar -xvf ffgv-hive-0.4.5.tar.gz && \
    cd ffgv-hive && \
    chmod +x ffgv

COPY entrypoint.sh /entrypoint.sh
COPY check_hashrate.py /check_hashrate.py

RUN sed -i 's/\r$//' /entrypoint.sh
RUN sed -i 's/\r$//' /check_hashrate.py
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
