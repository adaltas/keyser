#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__gpg'
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  mkdir -p $KEYSER_VAULT_DIR/some/target
  # Export the certificate
  res=`cert_export test.domain.com $KEYSER_VAULT_DIR/some/target`
  [[ $? != 0 ]] && exit 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.cert.pem ]] || exit 1
  [[ -f $KEYSER_VAULT_DIR/some/target/com.domain.test.key.pem ]] || exit 1
  echo $res | grep -F -- "-- key file: $KEYSER_VAULT_DIR/com.domain.test/key.pem" > /dev/null || exit 1
  echo $res | grep -F -- "-- cert file: $KEYSER_VAULT_DIR/com.domain.test/cert.pem" > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
