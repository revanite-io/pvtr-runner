FROM alpine:latest

LABEL author="Your Name/Org" \
      description="A robust wrapper to execute my CLI tool and upload results."

# Install dependencies, download Privateer, install binary, and clean up
RUN apk add --no-cache curl ca-certificates && \
    update-ca-certificates && \
    curl -L -o /tmp/privateer.tar.gz "https://github.com/privateerproj/privateer/releases/download/v0.8.0/privateer_Linux_x86_64.tar.gz" && \
    mkdir -p /opt/privateer && \
    tar -xzf /tmp/privateer.tar.gz -C /opt/privateer && \
    mv /opt/privateer/privateer /usr/local/bin/privateer && \
    chmod +x /usr/local/bin/privateer && \
    rm -rf /tmp/privateer.tar.gz /opt/privateer

ENTRYPOINT ["privateer", "-h"]