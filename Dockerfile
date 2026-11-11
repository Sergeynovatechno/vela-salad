FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Отключаем старые репозитории NVIDIA
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list

# Добавляем цикл повторных попыток на случай сбоя сети GitHub
RUN for i in 1 2 3 4 5; do \
    apt-get update && \
    apt-get install -y --no-install-recommends wget curl && break || sleep 5; \
    done

# Ставим ключи NVIDIA
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb

# Ставим остальные пакеты (снова с защитой от сбоя сети)
RUN for i in 1 2 3 4 5; do \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 python3-pip git libgl1 libglib2.0-0 && break || sleep 5; \
    done && \
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
