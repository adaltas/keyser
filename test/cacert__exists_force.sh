#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__exists_force'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Attempt to overwrite the certificate
  # cacert -f domain.com
  res=$(cacert -f -c FR -e no-reply@domain -l P -o O domain.com)
  [[ $? != 0 ]] && return 1
  echo "$res" | grep 'Certificate key created:' > /dev/null || return 1
  echo "$res" | grep 'Certificate authority created:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
