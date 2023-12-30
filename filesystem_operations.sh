#!/bin/bash

# Adjust permissions to satisfy certbot requirements
file_ops() {
chmod 0700 "$(dirname "${result_options["--dns-cloudflare-credentials"]}")"
chmod 0600 "${result_options["--dns-cloudflare-credentials"]}"

# Copy credentials file to the working folder

cp "${result_options["--dns-cloudflare-credentials"]}" .

# Check for ACL installation and set permissions

if command -v getfacl &>/dev/null && command -v setfacl &>/dev/null && command -v certbot &>/dev/null; then
    echo "ACL is installed. Setting permissions..."
    if [[ -n "${expected_args["setfacl_letsencrypt"]}" ]]; then
        echo -e "sudo setfacl -m u:"${expected_args["setfacl_letsencrypt"]}":rwx /etc/letsencrypt"
    else
        echo "No value provided for setfacl_letsencrypt."
        exit 1
    fi
else
    echo "Certbot and ACL are not installed. You need to do this first."
    exit 1
fi
}