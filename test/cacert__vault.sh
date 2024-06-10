#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__vault'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  res=`cacert -c FR -e no-reply@domain -l P -o O domain.com`
  [[ $? != 0 ]] && exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ]] || exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ]] || exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null || exit 1
  echo "$res" | grep 'Certificate authority created:' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
