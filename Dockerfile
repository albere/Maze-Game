FROM debian:bookworm-slim AS godot
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=type=tmpfs,target=/var/cache/apt \
    --mount=type=tmpfs,target=/var/lib/apt/lists \
    apt-get -qq update \
    && apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    libfontconfig-dev \
    unzip \
    wget \
    zip
ARG GODOT_VERSION="4.4"
ARG RELEASE_NAME="stable"
ARG GODOT_TEST_ARGS=""
ARG GODOT_PLATFORM="linux.x86_64"
RUN wget -q https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_PLATFORM}.zip \
    && mkdir -p ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && unzip -q Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_PLATFORM}.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_PLATFORM} /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_${GODOT_PLATFORM}.zip \
    && wget -q https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-${RELEASE_NAME}/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz \
    && unzip -q Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.${RELEASE_NAME} \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_export_templates.tpz


FROM godot AS builder
WORKDIR /src/build
COPY game .
RUN mkdir dist \
    && godot --verbose --headless --export-release "Web" --path . dist/index.html


FROM nginx
COPY --from=builder --chown=0:0 \
    /src/build/dist \
    /usr/share/nginx/html
