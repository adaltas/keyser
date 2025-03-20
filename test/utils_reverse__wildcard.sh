#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  local fqdn="*.domain.com"
  # local fqdn_dir="$KEYSER_VAULT_DIR/$(utils_reverse $fqdn)"
  local res=$KEYSER_VAULT_DIR/$(utils_reverse "$fqdn")
  [[ $? != 0 ]] && exit 1
  [[ $res == $KEYSER_VAULT_DIR'/com.domain.*' ]] || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
