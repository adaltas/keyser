#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../lib/api.sh

function test_cert_check_from_file__with_ca_file {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__with_ca_file'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Move parent certificate
  mv $KEYSER_VAULT_DIR/com.domain/cert.pem $KEYSER_VAULT_DIR/parent.cert.pem
  # Validate certificate
  res=`cert_check_from_file $KEYSER_VAULT_DIR/com.domain.test/cert.pem $KEYSER_VAULT_DIR/parent.cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cert_check_from_file__with_ca_file) && echo 'OK' || echo 'KO'
fi
