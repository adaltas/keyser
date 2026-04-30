#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_encrypt'
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  mkdir -p $KEYSER_VAULT_DIR
  echo "test content" > $KEYSER_VAULT_DIR/test.txt
  res=$(utils_encrypt $KEYSER_VAULT_DIR/test.txt $KEYSER_VAULT_DIR/test.txt.gpg) || return 1
  [[ -f $KEYSER_VAULT_DIR/test.txt.gpg ]] || return 1
  echo "$res" | grep 'test.txt.gpg' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
