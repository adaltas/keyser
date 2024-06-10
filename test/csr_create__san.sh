#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_create__san'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  csr_create -d domain.com,test.domain.com -a 127.0.0.1 -c FR -e no-reply@domain -l P -o O test.domain.com > /dev/null
  # SAN Validation
  res=`openssl req -text -in $KEYSER_VAULT_DIR/com.domain.test/cert.csr`
  [[ $? != 0 ]] && (echo $res && exit 1)
  echo "$res" | grep 'X509v3 Subject Alternative Name:' > /dev/null || exit 1
  echo "$res" | grep 'DNS:domain.com, DNS:test.domain.com, IP Address:127.0.0.1' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
