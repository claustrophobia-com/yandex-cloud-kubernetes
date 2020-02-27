#!/usr/bin/env bash
set -x
curl -o- https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash -s -- -i ./yc-cli -n
