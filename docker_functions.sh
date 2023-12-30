#!/bin/bash

# Create a container init script
docker_ops() {
cat <<EOF >container_init.sh
#!/bin/shift

# start the main application or service
exec "$@"

# Infinite loop to keep container running for debug
while true; do
    sleep 60

done
EOF

# Make executable
chmod +x container_init.sh

# Now create the Dockerfile and pass the credentials
echo -e "\nCreating Dockerfile...\n"

cat <<EOF >>Dockerfile
FROM $docker_os_image

COPY container_init.sh /root/

RUN echo "Credential file path: $credential_file"
RUN mkdir /root/.secrets
COPY "cloudflare.ini" "/root/.secrets"

# Update package lists and install required packages
RUN apt-get update && \\
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y python3-pip && \\
    pip3 install certbot certbot-dns-cloudflare && \\
    apt-get clean && \\
    rm -rf /var/lib/apt/lists/*
EOF

# Construct a Dockerfile so we can build our image
export CERTBOT_CMD="$certbot_cmd"
echo $CERTBOT_CMD

# start build process and then start container
echo -p "Docker compose build process starting, please wait..."
docker compose build --no-cache
echo -p "Docker container starting, please wait..."
docker compose -p "$(hostname)" up -d
}