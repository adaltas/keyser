#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__invalid_target_key_file'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Attempt to export the key on a directory
  mkdir -p "$KEYSER_VAULT_DIR"/some/target/com.domain.test.key.pem
  res=$(cert_export test.domain.com "$KEYSER_VAULT_DIR"/some/target)
  [[ $? == 1 ]] || return 1
  echo "$res" | grep 'Target key is not a file.' > /dev/null || return 1
  # Attempt to export the key on a file
  rm -r "$KEYSER_VAULT_DIR"/some/target/com.domain.test.key.pem
  touch "$KEYSER_VAULT_DIR"/some/target/com.domain.test.key.pem
  res=$(cert_export test.domain.com "$KEYSER_VAULT_DIR"/some/target)
  [[ $? == 1 ]] || return 1
  echo "$res" | grep 'Target key file already exists.' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
