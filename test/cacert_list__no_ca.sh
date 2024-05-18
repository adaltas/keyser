#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert_list__no_ca {
  KEYSER_VAULT_DIR='../tmp/test_cacert_list__no_ca'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # List all certificates from the vault
  res=`cacert_list`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'There are no registered certificate autority in this vault.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert_list__no_ca) && echo 'OK' || echo 'KO'
fi
