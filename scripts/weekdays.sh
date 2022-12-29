#!/usr/bin/env bash

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

# https://linuxconfig.org/how-to-list-only-work-days-using-shell-command-line-on-linux
ncal -h "$@" | grep -vE "^S|^ |^$" | sed "s/[[:alpha:]]//g" | tr -s ' ' | fmt -w 1 | sort -n
