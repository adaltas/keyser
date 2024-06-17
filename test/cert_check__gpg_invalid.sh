#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert'
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  echo 'invalid' > $KEYSER_VAULT_DIR/com.domain.test/cert.pem
  # Validate certificate
  res=`cert_check test.domain.com`
  [[ $? == 0 ]] && exit 1
  echo "$res" | grep 'Verification failed: `openssl verify` exit code is 2.' > /dev/null || exit 1
  [[ -f $KEYSER_VAULT_DIR/com.domain.test/key.pem ]] && exit 1
  true
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
