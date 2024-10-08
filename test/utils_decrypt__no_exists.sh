#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_decrypt__no_exists'
  KEYSER_GPG_PASSPHRASE=secret
  mkdir -p $KEYSER_VAULT_DIR
  res=`utils_decrypt $KEYSER_VAULT_DIR/does_not_exists $KEYSER_VAULT_DIR/target`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'No such file to decrypt.' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n " s$0: "
  (test) && echo 'OK' || echo 'KO'
fi
