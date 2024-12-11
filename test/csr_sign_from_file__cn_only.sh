#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/csr_sign_from_file__cn_only'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  mkdir -p $KEYSER_VAULT_DIR/tmp
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com >/dev/null
  # Create a certificate
  openssl req -newkey rsa:2048 -sha256 -nodes \
    -out $KEYSER_VAULT_DIR/tmp/cert.csr \
    -keyout $KEYSER_VAULT_DIR/tmp/key.pem \
    -subj "/CN=test.domain.com" 2>/dev/null
  # Sign the certificate
  res=`csr_sign_from_file "$KEYSER_VAULT_DIR/tmp/cert.csr" domain.com`
  [[ $? != 0 ]] && exit 1
  # Parent certificate is copied
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/ca.crt" ]] || exit 1
  # CRT is signed
  [[ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ]] || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
