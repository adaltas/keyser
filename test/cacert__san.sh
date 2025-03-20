#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__san'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -d local,localhost -a 127.0.0.1 -c PL -o "My Domain" -l Warsawa -e no-reply@domain.com domain.com > /dev/null
  # SAN Validation
  res=`openssl x509 -noout -ext subjectAltName -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | grep 'X509v3 Subject Alternative Name:' > /dev/null || exit 1
  echo "$res" | grep 'DNS:local, DNS:localhost, IP Address:127.0.0.1' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
