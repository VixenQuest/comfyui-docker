# ============================================================
# ComfyUI - SeedVR2 Image
# Python 3.11 | CUDA 12.8 | PyTorch 2.8
# ============================================================

FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/bin:$PATH"

# ── System dependencies + Python 3.11 via deadsnakes ─────────
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    git \
    git-lfs \
    wget \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    build-essential \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Set python3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Install pip via get-pip.py (cleanest method for Python 3.11)
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    python3.11 -m pip install --upgrade pip

# ── Git LFS ──────────────────────────────────────────────────
RUN git lfs install

# ── PyTorch 2.8 + CUDA 12.8 ──────────────────────────────────
RUN python3.11 -m pip install torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 \
    --index-url https://download.pytorch.org/whl/cu128

# ── Triton ───────────────────────────────────────────────────
RUN python3.11 -m pip install triton

# ── Flash Attention 2.8.3 (prebuilt wheel — cp311 + torch2.8 + cu128) ────────
RUN python3.11 -m pip install "https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.7.16/flash_attn-2.8.3+cu128torch2.8-cp311-cp311-linux_x86_64.whl"

# ── SageAttention 3 (Blackwell sm_120 explicitly targeted) ───
# TORCH_CUDA_ARCH_LIST must be set or the build silently skips sm_120
# and falls back to standard attention on Blackwell.
RUN TORCH_CUDA_ARCH_LIST="12.0" python3.11 -m pip install sageattention

# ── bitsandbytes (Blackwell-capable) ─────────────────────────
# NOTE: If a node segfaults on int8 matmul on Blackwell, load model
# in bf16/fp16 instead of 8-bit, or launch with BNB_CUDA_VERSION=0
RUN python3.11 -m pip install --upgrade bitsandbytes

# ── GitHub Auth ───────────────────────────────────────────────
ARG GITHUB_TOKEN
RUN git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# ── Clone ComfyUI (latest) ───────────────────────────────────
ARG CACHEBUST=1
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN python3.11 -m pip install -r /workspace/ComfyUI/requirements.txt

# ── Clear GitHub token from git config ───────────────────────
RUN git config --global --unset-all url."https://${GITHUB_TOKEN}@github.com/".insteadOf || true

# ── Pin transformers>=4.45.0 (required by SeedVR2) ───────────
# Custom nodes may pull an older version during their requirements installs.
# Force-reinstall here to guarantee SeedVR2 compatibility at container start.
RUN python3.11 -m pip install "transformers>=4.45.0" --force-reinstall

# ── JupyterLab ───────────────────────────────────────────────
RUN python3.11 -m pip install jupyterlab terminado

# ── Start script ─────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188
EXPOSE 8888
CMD ["/start.sh"]
