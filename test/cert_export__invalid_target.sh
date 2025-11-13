#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__invalid_target'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Attempt to export the key and the certificate
  res=$(cert_export test.domain.com "$KEYSER_VAULT_DIR"/some/target)
  [[ $? == 1 ]] || return 1
  echo "$res" | grep 'Target is not a directory.' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
