#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__force'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Attempt to export the key
  mkdir -p "$KEYSER_VAULT_DIR"/some/target
  touch "$KEYSER_VAULT_DIR"/some/target/com.domain.test.cert.pem
  touch "$KEYSER_VAULT_DIR"/some/target/com.domain.test.pem.pem
  cert_export -f test.domain.com "$KEYSER_VAULT_DIR"/some/target > /dev/null
  [[ $? != 0 ]] && return 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem ]] || return 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.key.pem ]] || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
