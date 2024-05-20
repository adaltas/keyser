#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__comment {
  KEYSER_VAULT_DIR='../tmp/test_cacert__comment'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.com domain.com > /dev/null
  # SAN Validation
  res=`openssl x509 -noout -ext nsComment -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | grep 'Netscape Comment:' > /dev/null
  echo "$res" | grep 'OpenSSL Generated Certificate by Keyser' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert__comment) && echo 'OK' || echo 'KO'
fi
