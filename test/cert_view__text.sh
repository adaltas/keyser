#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_view__text'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  res=$(cert_view -t test.domain.com)
  [[ $? != 0 ]] && return 1
  echo "$res" | grep 'Certificate:' > /dev/null || return 1
  echo "$res" | grep -E 'Subject: C ?= ?FR, O ?= ?O, L ?= ?P, CN ?= ?test.domain.com, emailAddress ?= ?no-reply@domain' > /dev/null || return 1
  echo "$res" | grep 'SHA1 Fingerprint=' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
