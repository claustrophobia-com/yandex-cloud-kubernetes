#!/usr/bin/env bash
eval "$(jq -r '@sh "USERNAME=\(.username) PASSWORD=\(.password)"')"

AUTH=$(htpasswd -nb ${USERNAME} ${PASSWORD})

jq -n --arg auth "$AUTH" '{"auth":$auth}'