#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cert_view {
  KEYSER_VAULT_DIR='../tmp/test_cert_view'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  res=`cert_view test.domain.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cert_view) && echo 'OK' || echo 'KO'
fi
