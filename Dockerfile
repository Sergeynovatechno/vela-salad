FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    wget \
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
