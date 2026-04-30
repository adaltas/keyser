#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

failed=0

for test in *.sh; do
  if [[ $test != "all.sh" ]]; then
    printf "%-50s" "$test"
    # shellcheck source=/dev/null
    . "$test"
    if test; then
      echo 'OK'
    else
      echo 'KO'
      failed=$((failed + 1))
    fi
  fi
done

if [[ $failed -gt 0 ]]; then
  exit 1
fi
