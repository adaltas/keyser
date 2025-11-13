#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_check_from_file__invalid'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # create an invalid certificate
  cacert -c FR -e no-reply@domain -l P -o O invalid.com > /dev/null
  cp -p "$KEYSER_VAULT_DIR/com.invalid/cert.pem" "$KEYSER_VAULT_DIR/com.domain/cert.pem"
  # Validate certificate
  res=$(cert_check_from_file "$KEYSER_VAULT_DIR/com.domain.test/cert.pem")
  [[ $? != 1 ]] && return 1
  echo "$res" | grep 'Verification failed:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
