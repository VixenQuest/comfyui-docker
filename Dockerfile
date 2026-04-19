# ============================================================
# ComfyUI - Main Stable Image
# Python 3.12 | CUDA 12.8 | PyTorch 2.7
# ============================================================

FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/local/bin:$PATH"

# ── System dependencies + Python 3.12 via deadsnakes ─────────
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
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

# Set python3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Install pip via get-pip.py (cleanest method for Python 3.12)
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12 && \
    python3.12 -m pip install --upgrade pip

# ── Git LFS ──────────────────────────────────────────────────
RUN git lfs install

# ── PyTorch 2.7 + CUDA 12.8 ──────────────────────────────────
RUN python3.12 -m pip install torch==2.7.0 torchvision==0.22.0 torchaudio==2.7.0 \
    --index-url https://download.pytorch.org/whl/cu128

# ── Triton ───────────────────────────────────────────────────
RUN python3.12 -m pip install triton

# ── Flash Attention 2.8.3 (HuggingFace hosted wheel) ─────────
RUN python3.12 -m pip install "https://huggingface.co/VixenQuest/Wheels/resolve/main/flash_attn-2.8.3%2Bcu128torch2.7-cp312-cp312-linux_x86_64.whl"

# ── SageAttention 3 ──────────────────────────────────────────
RUN python3.12 -m pip install sageattention

# ── GitHub Auth ───────────────────────────────────────────────
ARG GITHUB_TOKEN
RUN git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"

# ── Clone ComfyUI (latest) ───────────────────────────────────
ARG CACHEBUST=1
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
RUN python3.12 -m pip install -r /workspace/ComfyUI/requirements.txt

# ── Custom Nodes ─────────────────────────────────────────────

# ComfyUI-Manager
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Manager && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt

# ComfyUI-Easy-Use
RUN git clone https://github.com/yolain/ComfyUI-Easy-Use.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Easy-Use/requirements.txt

# ComfyUI-GGUF
RUN git clone https://github.com/city96/ComfyUI-GGUF.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-GGUF/requirements.txt

# rgthree-comfy
RUN git clone https://github.com/rgthree/rgthree-comfy.git \
    /workspace/ComfyUI/custom_nodes/rgthree-comfy && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/rgthree-comfy/requirements.txt

# ComfyUI-VideoHelperSuite
RUN git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-VideoHelperSuite/requirements.txt

# ComfyUI-WanVideoWrapper
RUN git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-WanVideoWrapper/requirements.txt

# ComfyUI-KJNodes
RUN git clone https://github.com/kijai/ComfyUI-KJNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes/requirements.txt

# comfyui_controlnet_aux
RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git \
    /workspace/ComfyUI/custom_nodes/comfyui_controlnet_aux && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/comfyui_controlnet_aux/requirements.txt

# ComfyUI-Impact-Pack
RUN git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Impact-Pack/requirements.txt

# ComfyUI_LayerStyle
RUN git clone https://github.com/chflame163/ComfyUI_LayerStyle.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_LayerStyle && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI_LayerStyle/requirements.txt

# ComfyUI-Custom-Scripts (pysssss)
RUN git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Custom-Scripts

# comfyui-crystools
RUN git clone https://github.com/crystian/ComfyUI-Crystools.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Crystools && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Crystools/requirements.txt

# ComfyUI-SAM3
RUN git clone https://github.com/facebookresearch/sam3.git \
    /workspace/ComfyUI/custom_nodes/sam3 && \
    if [ -f /workspace/ComfyUI/custom_nodes/sam3/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/sam3/requirements.txt; \
    fi

# ComfyUI-QwenVL
RUN git clone https://github.com/1038lab/ComfyUI-QwenVL.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-QwenVL && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-QwenVL/requirements.txt

# ComfyUI-VAE-Utils
RUN git clone https://github.com/spacepxl/ComfyUI-VAE-Utils.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-VAE-Utils && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-VAE-Utils/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-VAE-Utils/requirements.txt; \
    fi

# RyanOnTheInside
RUN git clone https://github.com/ryanontheinside/ComfyUI_RyanOnTheInside.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_RyanOnTheInside && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI_RyanOnTheInside/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI_RyanOnTheInside/requirements.txt; \
    fi

# comfyui_face_parsing
RUN git clone https://github.com/Ryuukeisyou/comfyui_face_parsing.git \
    /workspace/ComfyUI/custom_nodes/comfyui_face_parsing && \
    if [ -f /workspace/ComfyUI/custom_nodes/comfyui_face_parsing/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/comfyui_face_parsing/requirements.txt; \
    fi

# ComfyUI_essentials
RUN git clone https://github.com/cubiq/ComfyUI_essentials.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_essentials && \
    python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI_essentials/requirements.txt

# ComfyUI_UltimateSDUpscale
RUN git clone https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI_UltimateSDUpscale && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI_UltimateSDUpscale/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI_UltimateSDUpscale/requirements.txt; \
    fi

# ComfyUI-SeedVR2_VideoUpscaler
RUN git clone https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-SeedVR2_VideoUpscaler/requirements.txt; \
    fi

# ComfyUI-basic_data_handling
RUN git clone https://github.com/StableLlama/ComfyUI-basic_data_handling.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-basic_data_handling && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-basic_data_handling/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-basic_data_handling/requirements.txt; \
    fi

# ComfyUI-Dynamic-Lora-Scheduler
RUN git clone https://github.com/LeonQ8/ComfyUI-Dynamic-Lora-Scheduler.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-Dynamic-Lora-Scheduler && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-Dynamic-Lora-Scheduler/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-Dynamic-Lora-Scheduler/requirements.txt; \
    fi

# ComfyUI-SuperNodes
RUN git clone https://github.com/sonnybox/ComfyUI-SuperNodes.git \
    /workspace/ComfyUI/custom_nodes/ComfyUI-SuperNodes && \
    if [ -f /workspace/ComfyUI/custom_nodes/ComfyUI-SuperNodes/requirements.txt ]; then \
        python3.12 -m pip install -r /workspace/ComfyUI/custom_nodes/ComfyUI-SuperNodes/requirements.txt; \
    fi

# ── Clear GitHub token from git config ───────────────────────
RUN git config --global --unset-all url."https://${GITHUB_TOKEN}@github.com/".insteadOf || true

# ── Preloaded Workflows ──────────────────────────────────────
RUN mkdir -p /workspace/ComfyUI/user/default/workflows && \
    wget -q -O "/workspace/ComfyUI/user/default/workflows/Wan Animate - Head Swap.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/Wan%20Animate%20-%20Head%20Swap.json" && \
    wget -q -O "/workspace/ComfyUI/user/default/workflows/X QWEN Copycat (SAM3).json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/X%20QWEN%20Copycat%20(SAM3).json" && \
    wget -q -O "/workspace/ComfyUI/user/default/workflows/flux2_klein_control_net.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/flux2_klein_control_net.json" && \
    wget -q -O "/workspace/ComfyUI/user/default/workflows/video_ltx2_3_id_lora.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/video_ltx2_3_id_lora.json"

# ── JupyterLab ───────────────────────────────────────────────
RUN python3.12 -m pip install jupyterlab

# ── Start script ─────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8188
EXPOSE 8888
CMD ["/start.sh"]
