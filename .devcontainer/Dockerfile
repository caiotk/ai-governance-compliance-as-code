# Dev container / Codespace image with every CLI pinned to the versions CI uses.
FROM mcr.microsoft.com/devcontainers/python:3.12

ARG OPA_VERSION=1.21.2
ARG TERRAFORM_VERSION=1.13.4
ARG BICEP_VERSION=0.48.1

RUN set -eux; \
    apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*; \
    curl -sSL -o /usr/local/bin/opa "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64_static" && chmod +x /usr/local/bin/opa; \
    curl -sSL -o /tmp/tf.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && unzip -o /tmp/tf.zip -d /usr/local/bin && rm /tmp/tf.zip; \
    curl -sSL -o /usr/local/bin/bicep "https://github.com/Azure/bicep/releases/download/v${BICEP_VERSION}/bicep-linux-x64" && chmod +x /usr/local/bin/bicep; \
    opa version && terraform version && bicep --version

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt
