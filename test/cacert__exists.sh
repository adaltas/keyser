#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__exists {
  KEYSER_VAULT_DIR='../tmp/test_cacert__exists'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Attempt to overwrite the certificate
  res=`cacert -c FR -e no-reply@domain -l P -o O domain.com`
  [[ $? != 1 ]] && exit 1
  echo "$res" | grep 'CA certificate files already exists.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert__exists) && echo 'OK' || echo 'KO'
fi