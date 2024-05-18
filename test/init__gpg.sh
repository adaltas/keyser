#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_init__gpg {
  KEYSER_VAULT_DIR='../tmp/test_init'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Initialize a new vault
  out=`init`
  # Check the vault directory
  [[ -d "$KEYSER_VAULT_DIR" ]] || exit 1
  # In unencrypted mode, no gitignore
  [[ -f "$KEYSER_VAULT_DIR/.gitignore" ]] || exit 1
  # Check command output
  echo "$out" | grep 'Vault created: ' > /dev/null
  echo "$out" | grep 'Git .ignore file created: ' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_init__gpg) && echo 'OK' || echo 'KO'
fi
