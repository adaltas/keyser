#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

for test in *.sh; do
  if [[ $test != "all.sh" ]]; then
    printf "%-50s" "$test"
    # shellcheck source=/dev/null
    . "$test"
    (test && echo 'OK') || (echo 'KO' && exit 1)
  fi
done
