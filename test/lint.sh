#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

function test {
  if command -v shellcheck >/dev/null; then
    shellcheck -S warning -e SC2174 ../keyser
  else
    echo -n 'SKIP'
  fi
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
