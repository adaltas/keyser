#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_view'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Attempt to export the key
  mkdir -p $KEYSER_VAULT_DIR/some/target/com.domain.test.key.pem
  res=`cert_export test.domain.com $KEYSER_VAULT_DIR/some/target`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'Target key file already exists.' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
