#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_sign_from_file__san'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -d domain.com,test.domain.com -a 127.0.0.1 -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # Sign the certificate
  csr_sign_from_file -d domain.com,test.domain.com -a 127.0.0.1 "$KEYSER_VAULT_DIR/com.domain.test/cert.csr" > /dev/null
  # Validate SAN
  res=`openssl x509 -noout -ext subjectAltName -in $KEYSER_VAULT_DIR/com.domain.test/cert.pem`
  echo "$res" | grep 'X509v3 Subject Alternative Name:' > /dev/null || exit 1
  echo "$res" | grep 'DNS:domain.com, DNS:test.domain.com, IP Address:127.0.0.1' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
