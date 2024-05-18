#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_csr_sign__gpg {
  KEYSER_VAULT_DIR='../tmp/test_csr_sign__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign test.domain.com`
  [[ $? != 0 ]] && exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ]] || exit 1
  # [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem.gpg" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_csr_sign__gpg) && echo 'OK' || echo 'KO'
fi
