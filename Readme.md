# cf_cert_helper

A simple helper script for the Certbot Certificate Generator in combination with the Cloudflare DNS plugin.
The script will take care of installing the needed programs and dependencies within a docker container 
to generate a certificate.

The certbot flags "certonly --agree-tos --non-interactive --dns-cloudflare" will be added by default.


### Requirements

Docker and docker compose.

You must have a valid cloudflare api token stored in a file. If you do not specify a credentials file 
we will default to using the path: $HOME/.secrets/cloudflare.ini for the process.


### How to use

```
Usage: ./cf_cert_helper.sh [options]

Options:

credential_file=/path/credential_file              # Optional: Provide absolute path. Default: $HOME/.secrets/cloudflare.ini
domains=www.example.com                            # Required. Input the domain name or multiple using "," as a separator
propagation_seconds=10                             # Optional: Default 10 seconds
dry_run=true/false                                 # Optional: Certificate aquisition / renewal testing
clean_up=true/false                                # Optional: Remove credential files after build. Default is True.

```