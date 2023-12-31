#!/bin/bash

# Adjust permissions to satisfy certbot requirements
file_ops() {

local credentials_file="$1"

    # Adjust permissions to satisfy certbot requirements
    chmod 0700 "$(dirname "$credentials_file")"
    chmod 0600 "$credentials_file"

    # Copy credentials file to the working folder
    cp "$credentials_file" .

#Check for required programs

missing_programs=()

if ! command -v getfacl &>/dev/null; then
    missing_programs+=("getfacl")
fi

if ! command -v setfacl &>/dev/null; then
    missing_programs+=("setfacl")
fi

if ! command -v certbot &>/dev/null; then
    missing_programs+=("certbot")
fi

if ! (command -v docker &>/dev/null); then
    missing_programs+=("docker")
fi

if ! (command -v "docker-compose" &>/dev/null); then
    missing_programs+=("docker-compose")
fi

if ! (command -v "slirp4netns" &>/dev/null); then
    missing_programs+=("slirp4netns")
fi

if [ ${#missing_programs[@]} -gt 0 ]; then
    printf "The following programs were not found:\n\n"
    for program in "${missing_programs[@]}"; do
        echo "$program"
    done
    printf "\nPlease install them first.\n"
    rm "$dns_cloudflare_credentials_path"
    exit 1
else
    echo "All required tools are installed. Continuing..."
    # Additional logic here
fi
}
