#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  res=$(cacert -c FR -e no-reply@domain -l P -o O domain.com) || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ]] && return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain/key.pem.gpg" ]] || return 1
  echo "$res" | grep 'Certificate key created:' > /dev/null || return 1
  echo "$res" | grep 'Certificate authority created:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
