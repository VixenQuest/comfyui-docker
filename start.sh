#!/bin/bash
# ============================================================
# ComfyUI Startup Script for RunPod
# ============================================================

echo "=========================================="
echo " Starting ComfyUI..."
echo "=========================================="

# Symlink ComfyUI internal folders to persistent /workspace/ folders
# Existing folders are never deleted — symlinks are created only if not already present

if [ ! -L "/workspace/ComfyUI/models" ]; then
    mkdir -p /workspace/models
    ln -s /workspace/models /workspace/ComfyUI/models
    echo "✅ Models folder linked to /workspace/models"
else
    echo "✅ Models symlink already exists, skipping"
fi

if [ ! -L "/workspace/ComfyUI/output" ]; then
    mkdir -p /workspace/output
    ln -s /workspace/output /workspace/ComfyUI/output
    echo "✅ Output folder linked to /workspace/output"
else
    echo "✅ Output symlink already exists, skipping"
fi

if [ ! -L "/workspace/ComfyUI/input" ]; then
    mkdir -p /workspace/input
    ln -s /workspace/input /workspace/ComfyUI/input
    echo "✅ Input folder linked to /workspace/input"
else
    echo "✅ Input symlink already exists, skipping"
fi

if [ ! -L "/workspace/ComfyUI/custom_nodes" ]; then
    mkdir -p /workspace/custom_nodes
    ln -s /workspace/custom_nodes /workspace/ComfyUI/custom_nodes
    echo "✅ custom_nodes folder linked to /workspace/custom_nodes"
else
    echo "✅ custom_nodes symlink already exists, skipping"
fi

if [ ! -L "/workspace/ComfyUI/user/default/workflows" ]; then
    mkdir -p /workspace/workflows
    mkdir -p /workspace/ComfyUI/user/default
    ln -s /workspace/workflows /workspace/ComfyUI/user/default/workflows
    echo "✅ Workflows folder linked to /workspace/workflows"
else
    echo "✅ Workflows symlink already exists, skipping"
fi

# Seed workflows from HuggingFace if the folder is empty
if [ -z "$(ls -A /workspace/workflows 2>/dev/null)" ]; then
    echo "Seeding initial workflows..."
    wget -q -O "/workspace/workflows/Wan Animate - Head Swap.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/Wan%20Animate%20-%20Head%20Swap.json"
    wget -q -O "/workspace/workflows/X QWEN Copycat (SAM3).json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/X%20QWEN%20Copycat%20(SAM3).json"
    wget -q -O "/workspace/workflows/flux2_klein_control_net.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/flux2_klein_control_net.json"
    wget -q -O "/workspace/workflows/video_ltx2_3_id_lora.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/video_ltx2_3_id_lora.json"
    wget -q -O "/workspace/workflows/templates_hellorob_facegen_skindetail_upscale.json" \
        "https://huggingface.co/VixenQuest/Workflows/resolve/main/templates_hellorob_facegen_skindetail_upscale.json"
    echo "✅ Initial workflows seeded"
else
    echo "✅ Workflows already present, skipping seed"
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

# Start ComfyUI (Instance 1 - port 8188, SageAttention enabled)
echo "=========================================="
echo " Starting ComfyUI on port 8188..."
echo "=========================================="
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header --use-sage-attention &

# Start ComfyUI (Instance 2 - port 8189)
echo "=========================================="
echo " Starting ComfyUI on port 8189..."
echo "=========================================="
python main.py --listen 0.0.0.0 --port 8189 --enable-cors-header
