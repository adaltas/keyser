#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_utils_openssl_modulus__gpg {
  KEYSER_VAULT_DIR='../tmp/test_utils_openssl_modulus__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Create certificates
  cert a.domain.com > /dev/null
  cert b.domain.com > /dev/null
  utils_decrypt $KEYSER_VAULT_DIR/com.domain.a/key.pem.gpg $KEYSER_VAULT_DIR/com.domain.a/key.pem > /dev/null
  # Modulus match
  `utils_openssl_modulus $KEYSER_VAULT_DIR/com.domain.a/key.pem $KEYSER_VAULT_DIR/com.domain.a/cert.pem`
  [[ $? == 0 ]] || exit 1
  # Modulus dont match
  `utils_openssl_modulus $KEYSER_VAULT_DIR/com.domain.a/key.pem $KEYSER_VAULT_DIR/com.domain.b/cert.pem`
  [[ $? == 1 ]] || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_utils_openssl_modulus__gpg) && echo 'OK' || echo 'KO'
fi
