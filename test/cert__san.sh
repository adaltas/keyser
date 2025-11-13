#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

test() {
  KEYSER_VAULT_DIR='../tmp/cert__san'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificates
  cert -d domain.com,test.domain.com -a 127.0.0.1 test.domain.com >/dev/null
  # Validate SAN
  res=$(openssl x509 -noout -ext subjectAltName -in "$KEYSER_VAULT_DIR"/com.domain.test/cert.pem)
  echo "$res" | grep 'X509v3 Subject Alternative Name:' > /dev/null || return 1
  echo "$res" | grep 'DNS:domain.com, DNS:test.domain.com, IP Address:127.0.0.1' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
