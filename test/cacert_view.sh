#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert_view'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@adaltas.com -l Paris -o Adaltas domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null || exit 1
  echo "$res" | egrep 'Subject: C ?= ?FR, O ?= ?Adaltas, L ?= ?Paris, CN ?= ?domain.com, emailAddress ?= ?no-reply@adaltas.com' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
