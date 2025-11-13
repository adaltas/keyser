#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert_list__no_ca'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # List all certificates from the vault
  res=$(cacert_list) || return 1
  echo "$res" | grep 'There are no registered certificate autority in this vault.' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
