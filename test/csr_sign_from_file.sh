#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../lib/api.sh

function test_csr_sign_from_file {
  KEYSER_VAULT_DIR='../tmp/test_csr_sign_from_file'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign_from_file "$KEYSER_VAULT_DIR/com.domain.test/cert.csr"`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_csr_sign_from_file) && echo 'OK' || echo 'KO'
fi
