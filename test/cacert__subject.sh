#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__subject'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.com domain.com > /dev/null
  # Subject validation
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | egrep 'subject=C ?= ?PL, O ?= ?My Domain, L ?= ?Warsawa, CN ?= ?domain.com, emailAddress ?= ?no-reply@domain.com' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
