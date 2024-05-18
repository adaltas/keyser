#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_utils_decrypt__no_exists {
  KEYSER_VAULT_DIR='../tmp/test_utils_decrypt__no_exists'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  mkdir -p $KEYSER_VAULT_DIR
  res=`utils_decrypt $KEYSER_VAULT_DIR/does_not_exists $KEYSER_VAULT_DIR/target`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'No such file to decrypt.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n " s$0: "
  (test_utils_decrypt__no_exists) && echo 'OK' || echo 'KO'
fi
