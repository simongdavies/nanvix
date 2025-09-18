FROM scratch

LABEL org.opencontainers.image.runtime.name="hl-nanvix"
LABEL org.opencontainers.image.runtime.requirement="mandatory"
LABEL org.opencontainers.image.architecture="amd64"
LABEL org.opencontainers.image.os="nanvix"
LABEL org.opencontainers.image.platform="nanvix/amd64"

COPY ./bin /bin
ENV NANVIX_LOG_LEVEL=error
ENV NANVIX_LOG_DIR=./logs
