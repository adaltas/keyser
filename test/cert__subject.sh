#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

test_cert__san() {
  KEYSER_VAULT_DIR='../tmp/test_cert__san'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain.com -l P -o O domain.com >/dev/null
  # Create a certificates
  cert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.pl domain.pl domain.com >/dev/null
  # Validate subject
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/pl.domain/cert.pem`
  echo "$res" | grep 'subject=C=PL, O=My Domain, L=Warsawa, CN=domain.pl, emailAddress=no-reply@domain.pl' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cert__san) && echo 'OK' || echo 'KO'
fi
