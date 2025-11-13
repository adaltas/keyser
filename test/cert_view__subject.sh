#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_view__subject'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  res=$(cert_view -s test.domain.com) || return 1
  echo "$res" | grep 'Certificate:' > /dev/null && return 1
  echo "$res" | grep -E 'subject=C ?= ?FR, O ?= ?O, L ?= ?P, CN ?= ?test.domain.com, emailAddress ?= ?no-reply@domain' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
