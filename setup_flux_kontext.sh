#!/bin/bash
# ============================================================
# Baraa Studio — Flux Kontext Setup
# RTX 5090 32GB · Image Editing Workflow
# ============================================================

set -e
echo "🎬 Baraa Studio — Starting setup..."

# ── 1. ComfyUI ───────────────────────────────────────────────
if [ ! -d "/workspace/ComfyUI" ]; then
  echo "📦 Installing ComfyUI..."
  cd /workspace
  git clone https://github.com/comfyanonymous/ComfyUI.git
  cd ComfyUI
  pip install -r requirements.txt --break-system-packages
else
  echo "✅ ComfyUI already installed"
  cd /workspace/ComfyUI
  git pull
fi

# ── 2. Custom Nodes ──────────────────────────────────────────
echo "🔧 Installing custom nodes..."
cd /workspace/ComfyUI/custom_nodes

nodes=(
  "https://github.com/ltdrdata/ComfyUI-Manager.git"
  "https://github.com/kijai/ComfyUI-KJNodes.git"
  "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
  "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"
  "https://github.com/Fannovel16/comfyui_controlnet_aux.git"
  "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
  "https://github.com/yolain/ComfyUI-Easy-Use.git"
  "https://github.com/rgthree/rgthree-comfy.git"
)

for repo in "${nodes[@]}"; do
  name=$(basename "$repo" .git)
  if [ ! -d "$name" ]; then
    echo "  → Installing $name"
    git clone "$repo" || echo "  ⚠️  Failed: $name"
  else
    echo "  ✅ $name already installed"
  fi
done

# ── 3. Models — Flux Kontext (Image Editing) ─────────────────
echo "📥 Downloading models..."
cd /workspace/ComfyUI/models

# UNET — Flux Kontext fp8 (11.9GB)
if [ ! -f "unet/flux1-dev-kontext_fp8_scaled.safetensors" ]; then
  echo "  → Downloading Flux Kontext fp8 (~11.9GB)..."
  wget -q --show-progress \
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
    -O unet/flux1-dev-kontext_fp8_scaled.safetensors
else
  echo "  ✅ Flux Kontext already downloaded"
fi

# CLIP L
if [ ! -f "clip/clip_l.safetensors" ]; then
  echo "  → Downloading clip_l..."
  wget -q --show-progress \
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/text_encoders/clip_l.safetensors" \
    -O clip/clip_l.safetensors
else
  echo "  ✅ clip_l already downloaded"
fi

# T5XXL fp8
if [ ! -f "clip/t5xxl_fp8_e4m3fn.safetensors" ]; then
  echo "  → Downloading t5xxl_fp8..."
  wget -q --show-progress \
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn.safetensors" \
    -O clip/t5xxl_fp8_e4m3fn.safetensors
else
  echo "  ✅ t5xxl_fp8 already downloaded"
fi

# VAE — ae.safetensors
if [ ! -f "vae/ae.safetensors" ]; then
  echo "  → Downloading VAE..."
  wget -q --show-progress \
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/vae/ae.safetensors" \
    -O vae/ae.safetensors
else
  echo "  ✅ VAE already downloaded"
fi

# Upscaler 4x (optional but recommended)
mkdir -p upscale_models
if [ ! -f "upscale_models/4x_NMKD-Siax_200k.pth" ]; then
  echo "  → Downloading 4x Upscaler..."
  wget -q --show-progress \
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth" \
    -O upscale_models/4x_NMKD-Siax_200k.pth
else
  echo "  ✅ Upscaler already downloaded"
fi

# ── 4. Workflows ─────────────────────────────────────────────
echo "📋 Downloading workflows from GitHub..."
mkdir -p /workspace/ComfyUI/user/default/workflows

if [ -d "/tmp/baraa-workflows" ]; then
  rm -rf /tmp/baraa-workflows
fi

git clone https://github.com/Baraa7b7/comfyui-workflows.git /tmp/baraa-workflows 2>/dev/null || \
  echo "  ⚠️  Could not clone workflows repo — add them manually"

if [ -d "/tmp/baraa-workflows" ]; then
  cp -r /tmp/baraa-workflows/* /workspace/ComfyUI/user/default/workflows/ 2>/dev/null || true
  echo "  ✅ Workflows copied"
fi

# ── 5. Launch ComfyUI ────────────────────────────────────────
echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Starting ComfyUI..."
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 --fp8_e4m3fn-unet &

echo ""
echo "🎬 ComfyUI running at: http://localhost:8188"
echo "   Open in Vast.ai → Connect → Port 8188"
