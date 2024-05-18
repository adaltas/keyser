#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_csr_view {
  KEYSER_VAULT_DIR='../tmp/test_csr_view'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # View the certificate
  res=`csr_view test.domain.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate Request:' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_csr_view) && echo 'OK' || echo 'KO'
fi
