FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN rm -f /etc/apt/sources.list.d/cuda.list /etc/apt/sources.list.d/nvidia-ml.list
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    rm cuda-keyring_1.1-1_all.deb
RUN apt-get update -o Acquire::Retries=5 && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip wget libgl1 libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /root
RUN wget https://github.com/pepsykolya/FreeForGemVela/releases/download/v0.4.6/ffgv-hive-0.4.6.tar.gz && \
    tar -xvf ffgv-hive-0.4.6.tar.gz && \
    cd ffgv-hive && chmod +x ffgv
COPY entrypoint.sh /entrypoint.sh
COPY check_hashrate.py /check_hashrate.py
RUN sed -i 's/\r$//' /entrypoint.sh && \
    sed -i 's/\r$//' /check_hashrate.py && \
    chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
