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
else
    echo "No network volume detected, using local storage"
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
    --NotebookApp.token='' \
    --NotebookApp.password='' \
    --notebook-dir=/workspace \
    &

# Start ComfyUI
echo "=========================================="
echo " Starting ComfyUI..."
echo "=========================================="
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header
