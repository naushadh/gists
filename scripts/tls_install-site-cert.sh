#!/usr/bin/env bash

# https://unix.stackexchange.com/a/180729
extract_first_block() {
    start="$1"
    finish="$2"
    sed "/$start/,/$finish/!d;/$finish/q"
}

# https://superuser.com/a/641396
show_certificates(){
    host=$1
    port=${2:-443}
    openssl s_client -connect "$host:$port" -showcerts </dev/null 2>/dev/null
}

# https://community.jamf.com/t5/jamf-pro/problems-importing-cert-via-terminal/m-p/33370
macos_save_certificate(){
    cert_path="$1"
    # save to Default / Login keychain, which doesn't require root access
    security add-trusted-cert -k ~/Library/Keychains/login.keychain-db -r trustAsRoot "$cert_path"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename "$0") <host>"
    exit 1
fi

host=$1
cert_path="$HOME/Downloads/$host.crt"

show_certificates "$host" | extract_first_block '-----BEGIN CERTIFICATE-----' '-----END CERTIFICATE-----' > "$cert_path"
macos_save_certificate "$cert_path"
echo "$cert_path saved to login keychain"
