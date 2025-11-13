#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_decrypt__no_exists'
  KEYSER_GPG_PASSPHRASE=secret
  mkdir -p $KEYSER_VAULT_DIR
  res=$(utils_decrypt $KEYSER_VAULT_DIR/does_not_exists $KEYSER_VAULT_DIR/target) || return 1
  echo "$res" | grep 'No such file to decrypt.' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
