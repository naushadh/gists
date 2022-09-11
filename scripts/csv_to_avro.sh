#!/usr/bin/env bash

dir=$(realpath "${BASH_SOURCE%/*}")

docker run --rm -it \
  --volume "$dir/csv_to_avro.py":/app/csv_to_avro.py \
  --volume /tmp:/tmp \
  --volume "$HOME/Downloads:/$HOME/Downloads" \
  --volume "$PWD:/data" \
  --workdir /data \
  python:3.10-slim sh -c "pip install avro --quiet && /app/csv_to_avro.py $*"
