#!/usr/bin/env bash

# Requires $PAGERDUTY_TOKEN, read this doc to learn how to acquire it
# https://github.com/quandl/quandl-devops/blob/master/documentation/credentials.md#pagerduty

# Safties on: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

# Acquire these values from the Browser by inspecting network requests
SCHEDULE_ID=${SCHEDULE_ID:-FIXME1} # Some Policy
USER_ID=${USER_ID:-FIXME2} # Some body
START=${START:-'13:00:00'}
END=${END:-'21:00:00'}

curl --request POST "https://api.pagerduty.com/schedules/$SCHEDULE_ID/overrides/" \
  --header "Authorization: Token token=$PAGERDUTY_TOKEN" \
  --header 'Accept: application/vnd.pagerduty+json;version=2' \
  --header 'content-type: application/json' \
  --data "{
  \"overrides\": [{
    \"start\": \"${DATE}T${START}.000Z\",
    \"end\": \"${DATE}T${END}.000Z\",
    \"user\": {
      \"id\": \"$USER_ID\",
      \"type\": \"user_reference\"
    }
  }]
}"
