#!/bin/bash
# =============================================
# براء — Super Setup Script
# أمر واحد يجيب كل شيء
# استخدام: bash setup.sh YOUR_HF_TOKEN
# =============================================

HF_TOKEN=$1

if [ -z "$HF_TOKEN" ]; then
    echo "❌ لازم تحط الـ Hugging Face token"
    echo "استخدام: bash setup.sh YOUR_HF_TOKEN"
    exit 1
fi

echo "🚀 بدء الإعداد الكامل..."

cd /workspace/ComfyUI/custom_nodes

[ ! -d "ComfyUI-Manager" ] && git clone https://github.com/ltdrdata/ComfyUI-Manager.git
[ ! -d "ComfyUI-VideoHelperSuite" ] && git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git
[ ! -d "ComfyUI-WanVideoWrapper" ] && git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git
[ ! -d "ComfyUI-KJNodes" ] && git clone https://github.com/kijai/ComfyUI-KJNodes.git
[ ! -d "ComfyUI-Impact-Pack" ] && git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
[ ! -d "ComfyUI_IPAdapter_plus" ] && git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
[ ! -d "comfyui_controlnet_aux" ] && git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git

pip install -r ComfyUI-VideoHelperSuite/requirements.txt -q
pip install -r ComfyUI-Impact-Pack/requirements.txt -q
pip install -r comfyui_controlnet_aux/requirements.txt -q

echo "✅ النودات جاهزة"

cd /workspace/ComfyUI/models/diffusion_models
[ ! -f "flux1-dev-fp8.safetensors" ] && wget -q --show-progress --header="Authorization: Bearer $HF_TOKEN" "https://huggingface.co/Kijai/flux-fp8/resolve/main/flux1-dev-fp8.safetensors"
[ ! -f "wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" ] && wget -q --show-progress "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_2-I2V-14B-480P_fp8_e4m3fn.safetensors" -O wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors

cd /workspace/ComfyUI/models/vae
[ ! -f "ae.safetensors" ] && wget -q --show-progress --header="Authorization: Bearer $HF_TOKEN" "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors"
[ ! -f "wan_2.1_vae.safetensors" ] && wget -q --show-progress "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

cd /workspace/ComfyUI/models/clip
[ ! -f "clip_l.safetensors" ] && wget -q --show-progress "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
[ ! -f "t5xxl_fp8_e4m3fn.safetensors" ] && wget -q --show-progress "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
[ ! -f "umt5_xxl_fp8_e4m3fn_scaled.safetensors" ] && wget -q --show-progress "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors" -O umt5_xxl_fp8_e4m3fn_scaled.safetensors

cd /workspace/ComfyUI/models/clip_vision
[ ! -f "clip_vision_h.safetensors" ] && wget -q --show-progress "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"

mkdir -p /workspace/ComfyUI/models/ipadapter
cd /workspace/ComfyUI/models/ipadapter
[ ! -f "ip-adapter-plus_sdxl_vit-h.safetensors" ] && wget -q --show-progress "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors"

echo "✅ النماذج جاهزة"

mkdir -p /workspace/ComfyUI/user/default/workflows
cd /workspace/ComfyUI/user/default/workflows
[ ! -d ".git" ] && git clone https://github.com/Baraa7b7/comfyui-workflows.git . || git pull

echo "✅ الـ Workflows جاهزة"
echo ""
echo "🎬 الآن شغّل:"
echo "cd /workspace/ComfyUI && python main.py --listen 0.0.0.0 --port 8188 --fp8_e4m3fn-unet"
