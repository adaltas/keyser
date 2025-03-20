#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/init__metadata'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Initialize a new vault
  out=`init`
  # Check the metadata file
  cat "$KEYSER_VAULT_DIR/METADATA" | grep "VERSION=" > /dev/null || exit 1
  cat "$KEYSER_VAULT_DIR/METADATA" | grep "LAYOUT_VERSION=" > /dev/null || exit 1
  [[ $METADATA_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || exit 1
  [[ $METADATA_LAYOUT_VERSION =~ ^[0-9]+$ ]] || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
