#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/init__metadata'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Initialize a new vault
  init
  # Check the metadata file
  grep "VERSION=" "$KEYSER_VAULT_DIR/METADATA" > /dev/null 2>&1 || return 1
  grep "LAYOUT_VERSION=" "$KEYSER_VAULT_DIR/METADATA" > /dev/null 2>&1 || return 1
  [[ $METADATA_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || return 1
  [[ $METADATA_LAYOUT_VERSION =~ ^[0-9]+$ ]] || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
