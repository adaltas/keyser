#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

test() {
  KEYSER_VAULT_DIR='../tmp/cert__subject'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain.com -l P -o O domain.com >/dev/null
  # Create a certificates
  cert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.pl domain.pl domain.com >/dev/null
  # Validate subject
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/pl.domain/cert.pem`
  echo "$res" | egrep 'subject=C ?= ?PL, O ?= ?My Domain, L ?= ?Warsawa, CN ?= ?domain.pl, emailAddress ?= ?no-reply@domain.pl' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
