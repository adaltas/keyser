#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_csr_create__gpg {
  KEYSER_VAULT_DIR='../tmp/test_csr_create__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  res=`csr_create test.domain.com`
  [ $? != 0 ] && (echo $res && exit 1)
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem.gpg" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.csr" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_csr_create__gpg) && echo 'OK' || echo 'KO'
fi
