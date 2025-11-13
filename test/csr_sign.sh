#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_sign'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -c FR -e no-reply@domain -l P -o O test.domain.com >/dev/null
  # Sign the certificate
  res=$(csr_sign test.domain.com) || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ]] || return 1
  echo "$res" | grep 'Certificate created in:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
