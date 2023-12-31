#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cert_check_from_file__no_ca_file {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__no_ca_file'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Validate certificate
  res=`cert_check_from_file $KEYSER_VAULT_DIR/com.domain.test/cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cert_check_from_file__no_ca_file) && echo 'OK' || echo 'KO'
fi
