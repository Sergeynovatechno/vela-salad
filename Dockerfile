FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Вырезаем только сломанные строки NVIDIA из списков, оставляя стандартные Ubuntu
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list.d/*

# 2. Обновляем списки и ставим пакеты (с флагом повторных попыток на случай сбоя сети GitHub)
RUN apt-get update -o Acquire::Retries=8 && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    wget \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

# 3. Качаем майнер
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
