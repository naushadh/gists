#!/usr/bin/env bash

set -eu

# https://superuser.com/a/641396
show_certificates(){
    host=$1
    port=${2:-443}
    openssl s_client -connect "$host:$port" -showcerts </dev/null 2>/dev/null | openssl x509 -outform PEM
}

# https://community.jamf.com/t5/jamf-pro/problems-importing-cert-via-terminal/m-p/33370
macos_save_certificate(){
    cert_path="$1"
    # save to Default / Login keychain, which doesn't require root access
    security add-trusted-cert -k ~/Library/Keychains/login.keychain-db -r trustAsRoot "$cert_path"
}

# https://www.redhat.com/sysadmin/ca-certificates-cli
rhel_save_cerfiticate(){
    cert_path="$1"
    # Save to system trust store, will require root access
    cp "$cert_path" /etc/pki/ca-trust/source/anchors/
    update-ca-trust
}

get_linux_distro(){
    grep '^ID=' /etc/os-release | cut -d= -f2| tr -d '"'
}

save_certificate(){
    if [[ "$OSTYPE" == "darwin"* ]]; then
        macos_save_certificate "$1"
    elif [[ "$OSTYPE" == "linux-gnu"* && $(get_linux_distro) == "rhel" ]]; then
        rhel_save_cerfiticate "$1"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename "$0") <host>"
    exit 1
fi

host=$1
cert_path="$HOME/Downloads/$host.pem"

show_certificates "$host" > "$cert_path"
save_certificate "$cert_path"
echo "$cert_path added to trust store."
