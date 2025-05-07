FROM albere/godot-web:main AS builder
WORKDIR /src/build
COPY game .
RUN mkdir dist \
    && godot --verbose --headless --export-release "Web" --path . dist/index.html


FROM nginx
COPY --from=builder --chown=0:0 \
    /src/build/dist \
    /usr/share/nginx/html
