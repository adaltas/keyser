#!/bin/bash
# set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  # Generate a certificate authority
  version | grep -E '"[0-9]\.[0-9]\.[0-9]"' > /dev/null || return 1
  true
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
