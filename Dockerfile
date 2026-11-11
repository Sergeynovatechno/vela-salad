FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Временно отключаем репозитории NVIDIA, чтобы apt-get не ругался на ключи
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list

# 2. Обновляем apt и ставим wget и curl из стандартных репозиториев Ubuntu
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl && \
    rm -rf /var/lib/apt/lists/*

# 3. Скачиваем и устанавливаем новые ключи NVIDIA
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb

# 4. Теперь apt-get update сработает корректно, и мы ставим остальные пакеты
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    libgl1 \
    libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

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
