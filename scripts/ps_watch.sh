#!/usr/bin/env bash

# Use without args, or provide a shell command to be run on every invocation
# Helps create nice comparison between CPU/Memory use and some resource being operated; ex:
# ./scripts/ps_watch.sh wc -l ~/Downloads/images.csv
# See https://github.com/ServiceNow/PySNC/issues/107 for sample output

if [ "$#" -eq 0 ]; then
    cmd="echo ."
else
    cmd="$*"
fi

# Inspired from: https://superuser.com/a/696776 but should work where ever bash is available
while true; do ps auxw && $cmd; sleep 1; done
