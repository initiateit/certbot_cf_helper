#!/bin/bash

# Get cloudflare API token

cat <<EOF

cf_cert_gen

A simple helper for the Certbot Certificate Generator using the Cloudflare DNS plugin.
You must have a valid cloudflare api token and for security we will not hardcode anything.

Flags "certonly --agree-tos --non-interactive --dns-cloudflare" will be added by default.

Usage: cf_certgen [options]

Options:

credential_file=/path/credential_file                   # Optional: Provide absolute path. Default: $HOME/.secrets/cloudflare.ini
domains=www.example.com                                 # Required. Input the domain name or multiple using "," as a separator


EOF

# Define the expected argument names and their corrersponding Docker --build-args options in an associative array.

declare -A expected_args=(
    ["credential_file"]="--dns-cloudflare-credentials"
    ["domains"]="-d"
    ["propagation_seconds"]="--dns-cloudflare-propagation-seconds"
    ["dry_run"]="--dry-run"
    ["clean_up"]="--clean-up"
)

# Initialize the resulting associative array
declare -A result_options

# Init domains set to false
domains_set=false

# Initialize the credential_file variable with a dafult value
credential_file="$HOME/.secrets/cloudflare.ini"
result_options=["--dns-cloudflare-credentials"]=$credential_file

# Loop though the args and do some rudimentary checks
while [[ $# -gt 0 ]]; do
    arg="$1"
    name="${arg%%=*}"
    value="${arg#*=}"

    case "$name" in
    "domains")
        if [[ -n "$value" ]]; then
            result_options["-d"]=$value
        else
            echo "Error: you must specify at least one domain name."
            exit 1
        fi
        ;;
    "dry_run")
        case "$value" in
        "true")
            result_options["--dry-run"]=""
            ;;
        "false")
            # No need to pass --dry-run when its false, so not setting it here.
            ;;
        *)
            echo "Error: Invalid value for 'dry_run'. Use 'true' or 'false'."
            exit 1
            ;;
        esac
        ;;
    *)
        if [[ -n "${expected_args[$name]}" ]]; then
            if [[ -n "$value" ]]; then
                result_options["${expected_args[$name]}"]=$value
            else
                echo "Error: Argument '$name' is missing a value."
                exit 1
            fi
        else
            echo "Error: Unexpected argument '$name'."
        fi
        ;;
    esac

    shift
done

if [[ "$domains_set" == false ]]; then
    echo -e "Error: You must specify at least one domain name.\n"
    exit 1
fi

# Use credential_file in the file checks and operations
if [ -f "${result_options["--dns-cloudflare-credentials"]}" ]; then
    echo -e "credential_file exists at: ${result_options["--dns-cloudflare-credentials"]}\n"
    read -r -p "Would you like to overwrite this [y/N] " response
    response=${response,,}
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        echo "Please enter a valid Cloudflare API token (Note: Output is silent): "
        read -s CF_API_TOKEN

        while [[ -z "$CF_API_TOKEN" ]]; do
            echo "Token cant be blank, please re-enter: "
            read CF_API_TOKEN
        done

        echo -e "\nFile: ${result_options["--dns-cloudflare-credentials"]} was overwritten.\n"
        echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $CF_API_TOKEN" >"${result_options["--dns-cloudflare-credentials"]}"

    else
        :
    fi
else
    mkdir -p "$(dirname "${result_options["--dns-cloudflare-credentials"]}")"
    echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $CF_API_TOKEN" >"${result_options["--dns-cloudflare-credentials"]}"

fi

# Construct the certbot command using the result associative array
certbod_cmd="certbot certonly --dns-cloudflare --agree-tos --non-interactive"
for key in "${!result_options[@]}"; do
    certbod_cmd+="$key ${result_options[$key]}"
done

# Adjust permissions to satisfy certbot requirements

chmod 0700 "$(dirname "$credential_file")"
chmod 0600 "$credential_file"

# Copy credentials file to working folder

cp "$credential_file" .

# sort out file andf folder permissions so no root needed
while true; do
    cat <<EOF

Do you want to modify the hosts permissions for /etc/letsencrypt to grand read, write and 
execute (rwx) access to the Docker container? If you decline , the operation may fail 
unless the user has the necessary permissions or by using sudo.

EOF

    read -p "Enter Y for Yes, N for No: " yn
    case $yn in
    [Yy]*)
        read -p "Enter a group name for certbot docker actions: " certbot_group
        certbot_group=${certbot_group,,}
        read -p "Enter a username: " your_username
        username=${your_username,,}
        break
        ;;
    [Nn]*)
        echo "No group or username supplied."
        break
        ;;
    *)
        echo "Please answer y/n."
        ;;
    esac
done

echo -e "\nCreating Dockerfile...\n"

if [ -f "Dockerfile" ]; then
    read -p "Dockerfile detected, overwrite? [y/n]: " yn
    case $yn in
    [Yy]*)
        rm Dockerfile
        ;;
    [Nn]*)
        echo "Exiting, we cant continue without a valid Dockerfile."
        exit 1
        ;;
    *)
        echo "Please answer y/n."
        exit 1
        ;;
    esac
fi

#Next
