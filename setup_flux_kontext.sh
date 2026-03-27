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
  git checkout master 2>/dev/null || git checkout HEAD
  git pull || true
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

# ── 3. Models ────────────────────────────────────────────────
echo "📥 Downloading models..."
cd /workspace/ComfyUI/models

download() {
  local url=$1
  local out=$2
  if [ ! -f "$out" ] || [ ! -s "$out" ]; then
    echo "  → Downloading $(basename $out)..."
    curl -L --progress-bar "$url" -o "$out"
    local size=$(stat -c%s "$out" 2>/dev/null || echo 0)
    if [ "$size" -lt 1000000 ]; then
      echo "  ❌ FAILED: $(basename $out) is too small — check URL"
    else
      echo "  ✅ $(basename $out) done ($(numfmt --to=iec $size))"
    fi
  else
    echo "  ✅ $(basename $out) already exists"
  fi
}

download \
  "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
  "unet/flux1-dev-kontext_fp8_scaled.safetensors"

download \
  "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/text_encoders/clip_l.safetensors" \
  "clip/clip_l.safetensors"

download \
  "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/text_encoders/t5xxl_fp8_e4m3fn.safetensors" \
  "clip/t5xxl_fp8_e4m3fn.safetensors"

download \
  "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/vae/ae.safetensors" \
  "vae/ae.safetensors"

mkdir -p upscale_models
download \
  "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth" \
  "upscale_models/4x_NMKD-Siax_200k.pth"

# ── 4. Workflows ─────────────────────────────────────────────
echo "📋 Downloading workflows..."
mkdir -p /workspace/ComfyUI/user/default/workflows
rm -rf /tmp/baraa-workflows
git clone https://github.com/Baraa7b7/comfyui-workflows.git /tmp/baraa-workflows 2>/dev/null && \
  cp -r /tmp/baraa-workflows/* /workspace/ComfyUI/user/default/workflows/ 2>/dev/null && \
  echo "  ✅ Workflows copied" || \
  echo "  ⚠️  Could not clone workflows"

# ── 5. Launch ────────────────────────────────────────────────
echo ""
echo "✅ Setup complete!"
echo "🚀 Starting ComfyUI..."
cd /workspace/ComfyUI
python main.py --listen 0.0.0.0 --port 8188 &
echo "🎬 Open: http://localhost:8188"
