#!/bin/bash
# ============================================================
# ComfyUI Startup Script for RunPod
# ============================================================

echo "=========================================="
echo " Starting ComfyUI..."
echo "=========================================="

# If a network volume is mounted, symlink models folder to it
# so models persist between sessions
if [ -d "/runpod-volume" ]; then
    echo "Network volume detected at /runpod-volume"

    # Create models directory on volume if it doesn't exist
    mkdir -p /runpod-volume/models

    # Symlink ComfyUI models folder to the network volume
    if [ ! -L "/workspace/ComfyUI/models" ]; then
        rm -rf /workspace/ComfyUI/models
        ln -s /runpod-volume/models /workspace/ComfyUI/models
        echo "✅ Models folder linked to network volume"
    fi

    # Also persist outputs to network volume
    mkdir -p /runpod-volume/output
    if [ ! -L "/workspace/ComfyUI/output" ]; then
        rm -rf /workspace/ComfyUI/output
        ln -s /runpod-volume/output /workspace/ComfyUI/output
        echo "✅ Output folder linked to network volume"
    fi

    # Persist workflows to network volume
    mkdir -p /runpod-volume/workflows
    if [ ! -L "/workspace/ComfyUI/user/default/workflows" ]; then
        rm -rf /workspace/ComfyUI/user/default/workflows
        mkdir -p /workspace/ComfyUI/user/default
        ln -s /runpod-volume/workflows /workspace/ComfyUI/user/default/workflows
        echo "✅ Workflows folder linked to network volume"
    fi

    # Seed workflows from HuggingFace if the volume is empty
    if [ -z "$(ls -A /runpod-volume/workflows 2>/dev/null)" ]; then
        echo "Seeding initial workflows..."
        wget -q -O "/runpod-volume/workflows/Wan Animate - Head Swap.json" \
            "https://huggingface.co/VixenQuest/Workflows/resolve/main/Wan%20Animate%20-%20Head%20Swap.json"
        wget -q -O "/runpod-volume/workflows/X QWEN Copycat (SAM3).json" \
            "https://huggingface.co/VixenQuest/Workflows/resolve/main/X%20QWEN%20Copycat%20(SAM3).json"
        wget -q -O "/runpod-volume/workflows/flux2_klein_control_net.json" \
            "https://huggingface.co/VixenQuest/Workflows/resolve/main/flux2_klein_control_net.json"
        wget -q -O "/runpod-volume/workflows/video_ltx2_3_id_lora.json" \
            "https://huggingface.co/VixenQuest/Workflows/resolve/main/video_ltx2_3_id_lora.json"
        wget -q -O "/runpod-volume/workflows/templates_hellorob_facegen_skindetail_upscale.json" \
            "https://huggingface.co/VixenQuest/Workflows/resolve/main/templates_hellorob_facegen_skindetail_upscale.json"
        echo "✅ Initial workflows seeded"
    else
        echo "✅ Workflows already on network volume, skipping seed"
    fi
else
    echo "No network volume detected, using local storage"
    mkdir -p /workspace/ComfyUI/user/default/workflows
fi

# Start JupyterLab in the background
echo "=========================================="
echo " Starting JupyterLab..."
echo "=========================================="
jupyter lab \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --ServerApp.allow_remote_access=True \
    --ServerApp.root_dir=/workspace \
    &

# Start ComfyUI (Instance 1 - port 8188)
echo "=========================================="
echo " Starting ComfyUI on port 8188..."
echo "=========================================="
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header &

# Start ComfyUI (Instance 2 - port 8189)
echo "=========================================="
echo " Starting ComfyUI on port 8189..."
echo "=========================================="
python main.py --listen 0.0.0.0 --port 8189 --enable-cors-header
