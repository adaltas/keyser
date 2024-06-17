#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_check_from_file__with_ca_file'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Move parent certificate
  mv $KEYSER_VAULT_DIR/com.domain/cert.pem $KEYSER_VAULT_DIR/parent.cert.pem
  # Validate certificate
  # Provide the certificate as an argument
  res=`cert_check_from_file -a $KEYSER_VAULT_DIR/parent.cert.pem $KEYSER_VAULT_DIR/com.domain.test/cert.pem`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
