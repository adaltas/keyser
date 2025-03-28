#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_view__subject'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # View the certificate
  res=$(csr_view -s test.domain.com)
  [[ $? != 0 ]] && return 1
  # "Certificate Request" shall not be present
  echo "$res" | grep 'Certificate Request:' > /dev/null && return 1
  # Only the subject shall be present
  echo "$res" | grep -E 'subject=C ?= ?FR, O ?= ?O, L ?= ?P, CN ?= ?test.domain.com, emailAddress ?= ?no-reply@domain' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
