#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cert {
  KEYSER_VAULT_DIR='../tmp/test_cert'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  res=`cert test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/ca.crt" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cert) && echo 'OK' || echo 'KO'
fi
