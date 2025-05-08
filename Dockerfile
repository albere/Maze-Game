FROM debian:bookworm-slim AS godot-builder
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=type=tmpfs,target=/var/cache/apt \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    scons \
    pkg-config \
    libx11-dev \
    libxcursor-dev \
    libxinerama-dev \
    libgl1-mesa-dev \
    libglu-dev \
    libasound2-dev \
    libpng-dev \
    libpulse-dev \
    libfreetype6-dev \
    libssl-dev \
    libxrandr-dev \
    libudev-dev \
    libxi-dev \
    libxext-dev \
    zlib1g-dev \
    git \
    python3 \
    python3-pip \
    wget \
    unzip
WORKDIR /opt
RUN git clone https://github.com/emscripten-core/emsdk.git
WORKDIR /opt/emsdk
RUN ./emsdk install 3.1.62 \
    && ./emsdk activate 3.1.62 \
    && cat <<'EOF' > /opt/emscripten_setup.sh
#!/bin/bash
source /opt/emsdk/emsdk_env.sh
export PATH="/opt/emsdk:/opt/emsdk/upstream/emscripten:/opt/emsdk/upstream/bin:$PATH"
export EMSDK="/opt/emsdk"
export EM_CONFIG="/root/.emscripten"
export EMSCRIPTEN="/opt/emsdk/upstream/emscripten"
exec "$@"
EOF
RUN chmod +x /opt/emscripten_setup.sh
ARG GODOT_VERSION="4.4"
ARG GODOT_USE_LTO="yes"
ARG GODOT_OPTIMIZE="size"
ARG GODOT_DEBUG_SYMBOLS="no"
ARG GODOT_DISABLE_3D="yes"
ARG GODOT_DISABLE_ADVANCED_GUI="yes"
ARG GODOT_PRODUCTION="yes"
ARG GODOT_MINIZIP="yes"
ARG GODOT_MODULE_FREETYPE_ENABLED="yes"
ARG GODOT_MODULE_OGG_ENABLED="yes"
ARG GODOT_MODULE_VORBIS_ENABLED="yes"
ARG GODOT_MODULE_WEBM_ENABLED="yes"
ARG GODOT_MODULE_BULLET_ENABLED="yes"
ARG GODOT_MODULE_CSG_ENABLED="yes"
ARG GODOT_MODULE_GRIDMAP_ENABLED="yes"
ARG GODOT_MODULE_MOBILE_VR_ENABLED="no"
ARG GODOT_MODULE_CAMERA_ENABLED="yes"
ARG GODOT_MODULE_LIGHTMAP_ENABLED="no"
ARG GODOT_MODULE_RAYCAST_ENABLED="no"
ARG GODOT_MODULE_VHACD_ENABLED="yes"
ARG GODOT_MODULE_XATLAS_UNWRAP_ENABLED="no"
ARG GODOT_MODULE_3D_ENABLED="no"
ARG GODOT_MODULE_ARKIT_ENABLED="no"
ARG GODOT_MODULE_ASSIMP_ENABLED="yes"
ARG GODOT_MODULE_DDS_ENABLED="yes"
ARG GODOT_MODULE_GLTF_ENABLED="yes"
ARG GODOT_MODULE_HDR_ENABLED="yes"
ARG GODOT_MODULE_SVG_ENABLED="yes"
ARG GODOT_MODULE_TGA_ENABLED="yes"
ARG GODOT_MODULE_THEORA_ENABLED="yes"
ARG GODOT_MODULE_TINYEXR_ENABLED="yes"
ARG GODOT_MODULE_WEBP_ENABLED="yes"
ARG GODOT_MODULE_ENET_ENABLED="yes"
ARG GODOT_MODULE_JSONRPC_ENABLED="yes"
ARG GODOT_MODULE_MBEDTLS_ENABLED="yes"
ARG GODOT_MODULE_UPNP_ENABLED="yes"
ARG GODOT_MODULE_WEBRTC_ENABLED="no"
ARG GODOT_MODULE_WEBSOCKET_ENABLED="no"
ARG GODOT_MODULE_GDNATIVE_ENABLED="yes"
ARG GODOT_MODULE_MONO_ENABLED="no"
ARG GODOT_MODULE_OPENSIMPLEX_ENABLED="yes"
ARG GODOT_MODULE_OPUS_ENABLED="yes"
ARG GODOT_MODULE_REGEX_ENABLED="yes"
ARG GODOT_MODULE_SQUISH_ENABLED="yes"
ARG GODOT_MODULE_VISUAL_SCRIPT_ENABLED="no"
ARG GODOT_JAVASCRIPT_EVAL="yes"
ARG GODOT_THREADS_ENABLED="no"
WORKDIR /src
RUN git clone --branch ${GODOT_VERSION}-stable --depth 1 https://github.com/godotengine/godot.git
WORKDIR /src/godot
RUN /opt/emscripten_setup.sh scons platform=web target=template_release tools=no \
    use_lto=${GODOT_USE_LTO} \
    optimize=${GODOT_OPTIMIZE} \
    debug_symbols=${GODOT_DEBUG_SYMBOLS} \
    disable_3d=${GODOT_DISABLE_3D} \
    disable_advanced_gui=${GODOT_DISABLE_ADVANCED_GUI} \
    production=${GODOT_PRODUCTION} \
    minizip=${GODOT_MINIZIP} \
    module_freetype_enabled=${GODOT_MODULE_FREETYPE_ENABLED} \
    module_ogg_enabled=${GODOT_MODULE_OGG_ENABLED} \
    module_vorbis_enabled=${GODOT_MODULE_VORBIS_ENABLED} \
    module_webm_enabled=${GODOT_MODULE_WEBM_ENABLED} \
    module_bullet_enabled=${GODOT_MODULE_BULLET_ENABLED} \
    module_csg_enabled=${GODOT_MODULE_CSG_ENABLED} \
    module_gridmap_enabled=${GODOT_MODULE_GRIDMAP_ENABLED} \
    module_mobile_vr_enabled=${GODOT_MODULE_MOBILE_VR_ENABLED} \
    module_camera_enabled=${GODOT_MODULE_CAMERA_ENABLED} \
    module_lightmap_enabled=${GODOT_MODULE_LIGHTMAP_ENABLED} \
    module_raycast_enabled=${GODOT_MODULE_RAYCAST_ENABLED} \
    module_vhacd_enabled=${GODOT_MODULE_VHACD_ENABLED} \
    module_xatlas_unwrap_enabled=${GODOT_MODULE_XATLAS_UNWRAP_ENABLED} \
    module_3d_enabled=${GODOT_MODULE_3D_ENABLED} \
    module_arkit_enabled=${GODOT_MODULE_ARKIT_ENABLED} \
    module_assimp_enabled=${GODOT_MODULE_ASSIMP_ENABLED} \
    module_dds_enabled=${GODOT_MODULE_DDS_ENABLED} \
    module_gltf_enabled=${GODOT_MODULE_GLTF_ENABLED} \
    module_hdr_enabled=${GODOT_MODULE_HDR_ENABLED} \
    module_svg_enabled=${GODOT_MODULE_SVG_ENABLED} \
    module_tga_enabled=${GODOT_MODULE_TGA_ENABLED} \
    module_theora_enabled=${GODOT_MODULE_THEORA_ENABLED} \
    module_tinyexr_enabled=${GODOT_MODULE_TINYEXR_ENABLED} \
    module_webp_enabled=${GODOT_MODULE_WEBP_ENABLED} \
    module_enet_enabled=${GODOT_MODULE_ENET_ENABLED} \
    module_jsonrpc_enabled=${GODOT_MODULE_JSONRPC_ENABLED} \
    module_mbedtls_enabled=${GODOT_MODULE_MBEDTLS_ENABLED} \
    module_upnp_enabled=${GODOT_MODULE_UPNP_ENABLED} \
    module_webrtc_enabled=${GODOT_MODULE_WEBRTC_ENABLED} \
    module_websocket_enabled=${GODOT_MODULE_WEBSOCKET_ENABLED} \
    module_gdnative_enabled=${GODOT_MODULE_GDNATIVE_ENABLED} \
    module_mono_enabled=${GODOT_MODULE_MONO_ENABLED} \
    module_opensimplex_enabled=${GODOT_MODULE_OPENSIMPLEX_ENABLED} \
    module_opus_enabled=${GODOT_MODULE_OPUS_ENABLED} \
    module_regex_enabled=${GODOT_MODULE_REGEX_ENABLED} \
    module_squish_enabled=${GODOT_MODULE_SQUISH_ENABLED} \
    module_visual_script_enabled=${GODOT_MODULE_VISUAL_SCRIPT_ENABLED} \
    javascript_eval=${GODOT_JAVASCRIPT_EVAL} \
    threads_enabled=${GODOT_THREADS_ENABLED} \
    -j$(nproc) \
    && mkdir -p /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable/ \
    && cp -r bin/godot.web.template_release.wasm32.zip /root/.local/share/godot/export_templates/${GODOT_VERSION}.stable/


FROM albere/godot-web:main AS godot
COPY --from=godot-builder /root/.local/share/godot/export_templates /root/.local/share/godot/export_templates


FROM godot AS builder
WORKDIR /src/build
COPY game .
RUN mkdir dist \
    && godot --verbose --headless --export-release "Web" --path . dist/index.html


FROM nginx
COPY --from=builder --chown=0:0 \
    /src/build/dist \
    /usr/share/nginx/html
