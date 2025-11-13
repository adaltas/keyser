#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert__wildcard'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a wildcard certificate
  res=$(cert "*.domain.com") || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.*/ca.crt" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.*/cert.pem" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain.*/key.pem" ]] || return 1
  echo "$res" | grep 'Key created in:' > /dev/null || return 1
  echo "$res" | grep 'CSR created in:' > /dev/null || return 1
  echo "$res" | grep 'Certificate created in:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
