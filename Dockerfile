# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.8.4-base

# build-time tokens for gated downloads — never baked into final image.
# pass via: docker build --build-arg HF_TOKEN=$HF_TOKEN ...
ARG CIVITAI_API_KEY=""

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui-custom-scripts --mode remote
RUN comfy node install --exit-on-fail rgthree-comfy
RUN comfy node install --exit-on-fail comfyui-florence2
RUN comfy node install --exit-on-fail cg-use-everywhere
RUN git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes
RUN comfy node install --exit-on-fail comfyui_layerstyle_advance
RUN comfy node install --exit-on-fail comfyui_essentials
RUN comfy node install --exit-on-fail comfyui_face_parsing
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui /comfyui/custom_nodes/masquerade-nodes-comfyui

# download models into comfyui
RUN BACKOFFS="60 300 900 1800 3600" && for i in 1 2 3 4 5; do CIVITAI_API_KEY=$CIVITAI_API_KEY comfy model download --url 'https://civitai.com/api/download/models/3058932?token=1bd2ef73360d07bfa008cebe4b3018f1' --relative-path models/checkpoints --filename 'epicrealismXL_v8Kiss.safetensors' && break; if [ $i -eq 5 ]; then echo "model-download failed after 5 attempts" >&2; exit 1; fi; SLEEP=$(echo $BACKOFFS | cut -d ' ' -f $i) && echo "model-download attempt $i failed; retrying in $SLEEP seconds" >&2; sleep $SLEEP; done

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/

# user-provided inputs override the auto-generated placeholders above.
RUN wget --progress=dot:giga -O '/comfyui/input/00004-1323283763.png' "https://cool-anteater-319.convex.cloud/api/storage/62c85b54-3858-4e12-bff8-3cb5ff5970b0"
