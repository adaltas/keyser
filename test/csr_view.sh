#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_view'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # View the certificate
  res=$(csr_view test.domain.com) || return 1
  echo "$res" | grep 'Certificate Request:' > /dev/null || return 1
  echo "$res" | grep -E 'Subject: C ?= ?FR, O ?= ?O, L ?= ?P, CN ?= ?test.domain.com, emailAddress ?= ?no-reply@domain' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
