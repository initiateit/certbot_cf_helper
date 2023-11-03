# cf_cert_gen

A simple helper for the Certbot Certificate Generator using the Cloudflare DNS plugin.
You must have a valid cloudflare api token and for security we will not hardcode anything.

Flags "certonly --agree-tos --non-interactive --dns-cloudflare" will be added by default.

```
Usage: cf_certgen [options]

Options:

credential_file=/path/credential_file                   # Optional: Provide absolute path. Default: $HOME/.secrets/cloudflare.ini
domains=www.example.com                                 # Required. Input the domain name or multiple using "," as a separator
```