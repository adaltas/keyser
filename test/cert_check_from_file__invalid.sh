#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cert_check_from_file__invalid {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__invalid'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # create an invalid certificate
  cacert invalid.com > /dev/null
  cp -rp "$KEYSER_VAULT_DIR/com.invalid/cert.pem" "$KEYSER_VAULT_DIR/com.domain/cert.pem"
  # Validate certificate
  res=`cert_check_from_file "$KEYSER_VAULT_DIR/com.domain.test/cert.pem"`
  [[ $? != 1 ]] && exit 1
  echo "$res" | grep 'Certificate is not valid.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cert_check_from_file__invalid) && echo 'OK' || echo 'KO'
fi
