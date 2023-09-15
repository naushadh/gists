#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "No argument is given"
  echo "Usage: $(basename "$0") <class name>"
  exit 1
fi

if [ -z "$BITBUCKET_URL" ]; then
    echo "\$BITBUCKET_URL is empty. Please set it as ENV var"
    exit 2
fi

if [ -z "$BITBUCKET_OAUTH_TOKEN" ]; then
    echo "\$BITBUCKET_OAUTH_TOKEN is empty. Please generate (https://confluence.atlassian.com/bitbucketserver0712/personal-access-tokens-1063557386.html) and set it as ENV var"
    exit 2
fi

search(){
    query=$1

    # TODO: add pagination
    curl "${BITBUCKET_URL}/rest/search/latest/search?avatarSize=64" \
        --header 'Accept: application/json, text/javascript, */*; q=0.01' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $BITBUCKET_OAUTH_TOKEN" \
        --data-raw "{\"query\":\"$query\",\"entities\":{\"code\":{\"start\":0,\"limit\":100}}}" \
        --silent \
        --compressed
}

find_repo_references(){
    search "$1" | jq -rM '.code.values[].repository | [.project.name, .name] | @csv' | tr -d '"' | sort --unique
}

find_repo_references "$1"
