#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert_view'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@adaltas.com -l Paris -o Adaltas domain.com > /dev/null
  # Validate certificate
  res=$(cacert_view -t domain.com) || return 1
  echo "$res" | grep 'Certificate:' > /dev/null || return 1
  echo "$res" | grep -E 'Subject: C ?= ?FR, O ?= ?Adaltas, L ?= ?Paris, CN ?= ?domain.com, emailAddress ?= ?no-reply@adaltas.com' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
