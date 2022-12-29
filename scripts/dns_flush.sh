#!/usr/bin/env bash

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

# https://www.igeeksblog.com/how-to-flush-dns-in-mac-os-x/
dscacheutil -flushcache
killall -HUP mDNSResponder
