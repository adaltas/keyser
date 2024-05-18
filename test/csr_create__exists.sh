#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_csr_create__exists {
  KEYSER_VAULT_DIR='../tmp/test_csr_create__exists'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com > /dev/null
  res=`csr_create test.domain.com`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'FQDN repository already exists.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_csr_create__exists) && echo 'OK' || echo 'KO'
fi
