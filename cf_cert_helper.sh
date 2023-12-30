#!/bin/bash

source docker_functions.sh
source filesystem_operations.sh
source clean_up.sh

# Define the expected argument names in an associative array.

declare -A expected_args=(
    ["credential_file"]="--dns-cloudflare-credentials"
    ["cf_api_token"]=""
    ["overwrite_cred_file"]=""
    ["domains"]="-d"
    ["propagation_seconds"]="--dns-cloudflare-propagation-seconds"
    ["setfacl_letsencrypt"]=""
    ["dry_run"]="--dry-run"
    ["clean_up"]="--clean-up"
)

# Initialize the resulting associative array
declare -A result_options
domains_set=false

# Loop through the args and do some rudimentary checks
for arg in "$@"; do
    name="${arg%%=*}"
    value="${arg#*=}"

    case "$name" in
    "cf_api_token")
        expected_args["cf_api_token"]="$value"
        ;;
    "overwrite_cred_file")
        expected_args["overwrite_cred_file"]="$value"
        ;;
    "domains")
        if [[ -n "$value" ]]; then
            result_options["-d"]="$value"
            domains_set=true
        else
            echo "Error: you must specify at least one domain name."
            exit 1
        fi
        ;;
    "setfacl_letsencrypt")
        expected_args["setfacl_letsencrypt"]="$value"
        ;;
    *)
        if [[ -n "${expected_args[$name]}" ]]; then
            if [[ -n "$value" ]]; then
                result_options["${expected_args[$name]}"]="$value"
            else
                echo "Error: Argument '$name' is missing a value."
                exit 1
            fi
        else
            echo "Error: Unexpected argument '$name'."
            exit 1
        fi
        ;;
    esac
done

if [[ "$domains_set" == false ]]; then
    echo -e "Error: You must specify at least one domain name.\n"
    exit 1
fi

if [[ "${expected_args["overwrite_cred_file"]}" != "true" ]]; then
    echo "overwrite_cred_file not set to true. Exiting."
    exit 1
fi

if [[ -z "${result_options["--dns-cloudflare-credentials"]}" ]]; then
    result_options["--dns-cloudflare-credentials"]="$HOME/.secrets/cloudflare.ini"
fi

if [ -f "${result_options["--dns-cloudflare-credentials"]}" ]; then
    echo -e "Credential file exists at: ${result_options["--dns-cloudflare-credentials"]}\n"
    echo -e "\nFile: ${result_options["--dns-cloudflare-credentials"]} was overwritten.\n"
    echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = ${expected_args["cf_api_token"]}" >"${result_options["--dns-cloudflare-credentials"]}"
else
    mkdir -p "$(dirname "${result_options["--dns-cloudflare-credentials"]}")"
    echo -e "# Cloudflare API token used by Certbot\ndns_cloudflare_api_token = ${expected_args["cf_api_token"]}" >"${result_options["--dns-cloudflare-credentials"]}"
fi

# Save the credential file path to a variable
dns_cloudflare_credentials_path="${result_options["--dns-cloudflare-credentials"]}"

# Construct the certbot command using the result associative array
certbod_cmd="certbot certonly --dns-cloudflare --agree-tos --non-interactive"
for key in "${!result_options[@]}"; do
    certbod_cmd+=" $key ${result_options[$key]}"
done

file_ops
#docker_ops

if [[ ${expected_args["clean_up"]} != false ]]; then
    clean_files "$dns_cloudflare_credentials_path"
else
    echo "Not cleaning up. Exiting."
    exit 1
fi


