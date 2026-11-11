FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Удаляем старые сломанные списки NVIDIA
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list

# 2. Ставим актуальный ключ безопасности NVIDIA
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    rm cuda-keyring_1.0-1_all.deb

# 3. Обновляем и ставим пакеты
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

# 4. Качаем майнер
RUN wget https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.5/ffgv-hive-0.4.5.tar.gz && \
    tar -xvf ffgv-hive-0.4.5.tar.gz && \
    cd ffgv-hive && \
    chmod +x ffgv

# 5. Копируем скрипты
COPY entrypoint.sh /entrypoint.sh
COPY check_hashrate.py /check_hashrate.py

# 6. Чистим от символов Windows
RUN sed -i 's/\r$//' /entrypoint.sh && \
    sed -i 's/\r$//' /check_hashrate.py && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
