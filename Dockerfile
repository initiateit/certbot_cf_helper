FROM ubuntu:latest

COPY container_init.sh /root/

RUN echo "Credential file path: $credential_file"
RUN mkdir /root/.secrets
COPY "cloudflare.ini" "/root/.secrets"

# Update package lists and install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y python3-pip && \
    pip3 install certbot certbot-dns-cloudflare && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
