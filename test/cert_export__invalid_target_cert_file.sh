#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__invalid_target_cert_file'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Attempt to export the key on a directory
  mkdir -p $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem
  res=`cert_export test.domain.com $KEYSER_VAULT_DIR/some/target`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'Target certificate is not a file.' > /dev/null || exit 1
  # Attempt to export the key on a file
  rm -r $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem
  touch $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem
  res=`cert_export test.domain.com $KEYSER_VAULT_DIR/some/target`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'Target certificate file already exists.' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
