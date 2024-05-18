#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__force_false {
  KEYSER_VAULT_DIR='../tmp/test_cacert__force_false'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Attempt to overwrite the certificate
  res=`cacert domain.com`
  [[ $? != 1 ]] && exit 1
  echo "$res" | grep 'CA certificate files already exists.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert__force_false) && echo 'OK' || echo 'KO'
fi
