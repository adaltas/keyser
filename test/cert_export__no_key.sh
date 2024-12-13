#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert_export__no_key'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  mkdir -p $KEYSER_VAULT_DIR/tmp
  mkdir -p $KEYSER_VAULT_DIR/export
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create a CSR
  openssl req -newkey rsa:2048 -sha256 -nodes \
    -out $KEYSER_VAULT_DIR/tmp/cert.csr \
    -keyout $KEYSER_VAULT_DIR/tmp/key.pem \
    -subj "/CN=test.domain.com" 2>/dev/null
  # Sign the certificate
  csr_sign_from_file "$KEYSER_VAULT_DIR/tmp/cert.csr" domain.com > /dev/null
  # Export the certificate
  res=`cert_export test.domain.com $KEYSER_VAULT_DIR/export`
  [[ $? != 0 ]] && exit 1
  [[ -f $KEYSER_VAULT_DIR/export/com.domain.test.cert.pem ]] || exit 1
  [[ ! -f $KEYSER_VAULT_DIR/export/com.domain.test.key.pem ]] || exit 1
  echo $res | grep -F -- "-- key file: $KEYSER_VAULT_DIR/com.domain.test/key.pem" > /dev/null && exit 1
  echo $res | grep -F -- "-- cert file: $KEYSER_VAULT_DIR/com.domain.test/cert.pem" > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
