#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/init'
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Initialize a new vault
  out=$(init)
  # Check the vault directory
  [[ -d "$KEYSER_VAULT_DIR" ]] || return 1
  # In unencrypted mode, no gitignore
  [[ -f "$KEYSER_VAULT_DIR/.gitignore" ]] || return 1
  # Check command output
  echo "$out" | grep 'Vault created: ' > /dev/null || return 1
  echo "$out" | grep 'Git .ignore file created: ' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
