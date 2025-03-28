#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  mkdir -p $KEYSER_VAULT_DIR/some/target
  # Export the certificate
  res=$(cert_export test.domain.com $KEYSER_VAULT_DIR/some/target)
  [[ $? != 0 ]] && return 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem ]] || return 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.key.pem ]] || return 1
  echo "$res" | grep -F -- "-- key file: $KEYSER_VAULT_DIR/com.domain.test/key.pem" > /dev/null || return 1
  echo "$res" | grep -F -- "-- cert file: $KEYSER_VAULT_DIR/com.domain.test/cert.pem" > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
