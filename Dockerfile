# syntax=docker/dockerfile:1
FROM alpine:latest AS build

WORKDIR /build

LABEL author="revanite.io" \
      description=""

ARG DEFAULT_PVTR_VERSION=0.8.0
ENV PVTR_VERSION=${DEFAULT_PVTR_VERSION}

ARG DEFAULT_GITHUB_PLUGIN_VERSION
ENV GITHUB_PLUGIN_VERSION=${DEFAULT_GITHUB_PLUGIN_VERSION}

RUN apk add --no-cache curl ca-certificates tar gzip
RUN update-ca-certificates
RUN curl -L -o privateer.tar.gz "https://github.com/privateerproj/privateer/releases/download/v${PVTR_VERSION}/privateer_Linux_x86_64.tar.gz"
RUN tar -xzf privateer.tar.gz
RUN chmod +x privateer

FROM scratch
COPY --from=build /build/privateer /bin/privateer

ENTRYPOINT ["/bin/privateer", "-h"]