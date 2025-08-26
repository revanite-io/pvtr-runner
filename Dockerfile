FROM alpine:latest

LABEL author="Your Name/Org" \
      description="A robust wrapper to execute my CLI tool and upload results."

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install your CLI tool and dependencies here
# Example placeholders:
# RUN apk add --no-cache curl bash jq
# RUN wget -O /usr/local/bin/my-cli https://example.com/my-cli && chmod +x /usr/local/bin/my-cli
# Or, for Python-based tools:
# RUN apk add --no-cache python3 py3-pip && pip install --no-cache-dir my-cli

ENTRYPOINT ["/entrypoint.sh"]


