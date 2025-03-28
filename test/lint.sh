#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
    shellcheck -S warning -e SC2140 -e SC1078 -e SC1079 -e SC2174 -e SC2155 ../keyser
  if command -v shellcheck >/dev/null; then
  else
    echo -n 'SKIP'
  fi
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
