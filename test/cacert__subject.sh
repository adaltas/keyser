#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__subject {
  KEYSER_VAULT_DIR='../tmp/test_cacert__subject'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.com domain.com > /dev/null
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | grep 'subject=C=PL, O=My Domain, L=Warsawa, CN=domain.com, emailAddress=no-reply@domain.com' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert__subject) && echo 'OK' || echo 'KO'
fi
