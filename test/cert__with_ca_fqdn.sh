#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert__with_ca_fqdn'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain-1.com > /dev/null
  # Create a certificate
  res=`cert test.domain-2.com domain-1.com`
  # Validate execution
  [[ $? != 0 ]] && exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/ca.crt" ]] || exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/cert.pem" ]] || exit 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/key.pem" ]] || exit 1
  # Make sure the ca.crt is correctly generated
  cacertin=`openssl x509 -noout -fingerprint -in $KEYSER_VAULT_DIR/com.domain-1/cert.pem`
  cacertout=`openssl x509 -noout -fingerprint -in $KEYSER_VAULT_DIR/com.domain-2.test/ca.crt`
  [[ $cacertin == $cacertout ]] || exit 1
  cert_check_from_file -a $KEYSER_VAULT_DIR/com.domain-2.test/ca.crt $KEYSER_VAULT_DIR/com.domain-2.test/cert.pem > /dev/null
  [[ $? != 0 ]] && exit 1
  # Validate output
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
