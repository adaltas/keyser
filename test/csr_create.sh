#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_create'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  res=$(csr_create -c FR -e no-reply@domain -l P -o O test.domain.com) || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.csr" ]] || return 1
  echo "$res" | grep 'Key created in:' > /dev/null || return 1
  echo "$res" | grep 'CSR created in:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
