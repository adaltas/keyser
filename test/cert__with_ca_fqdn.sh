#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cert__with_ca_fqdn'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain-1.com > /dev/null
  # Create a certificate
  res=$(cert test.domain-2.com domain-1.com) || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/ca.crt" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/cert.pem" ]] || return 1
  [[ -f "$KEYSER_VAULT_DIR/com.domain-2.test/key.pem" ]] || return 1
  # Make sure the ca.crt is correctly generated
  cacertin=$(openssl x509 -noout -fingerprint -in "$KEYSER_VAULT_DIR"/com.domain-1/cert.pem)
  cacertout=$(openssl x509 -noout -fingerprint -in "$KEYSER_VAULT_DIR"/com.domain-2.test/ca.crt)
  [[ $cacertin == "$cacertout" ]] || return 1
  cert_check_from_file \
    -a "$KEYSER_VAULT_DIR"/com.domain-2.test/ca.crt \
    "$KEYSER_VAULT_DIR"/com.domain-2.test/cert.pem \
  > /dev/null || return 1
  # Validate output
  echo "$res" | grep 'Key created in:' > /dev/null || return 1
  echo "$res" | grep 'CSR created in:' > /dev/null || return 1
  echo "$res" | grep 'Certificate created in:' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
