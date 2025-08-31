# syntax=docker/dockerfile:1
FROM alpine:latest AS build

WORKDIR /build

LABEL author="revanite.io" \
      description=""

ARG PVTR_VERSION=0.8.0
ARG PLUGIN_VERSION=0.1.0

RUN apk add --no-cache curl ca-certificates tar gzip && \
    update-ca-certificates && \
    curl -L -o privateer.tar.gz "https://github.com/privateerproj/privateer/releases/download/v${PVTR_VERSION}/privateer_Linux_x86_64.tar.gz" && \
    tar -xzf privateer.tar.gz && \
    chmod +x privateer
RUN curl -L -o pvtr-github-repo.tar.gz "https://github.com/revanite-io/pvtr-github-repo/releases/download/v${PLUGIN_VERSION}/pvtr-github-repo_{$PLUGIN_VERSION}_linux_386.tar.gz" && \
    tar -xzf pvtr-github-repo.tar.gz && \
    chmod +x pvtr-github-repo

FROM scratch

COPY --from=build /build/privateer /bin/privateer
COPY --from=build /build/pvtr-github-repo /bin/pvtr-plugins/pvtr-github-repo

WORKDIR /pvtr-run
COPY config-template.yml config-template.yml

ENTRYPOINT ["/bin/privateer", "list", "-b", "/bin/pvtr-plugins"]