#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__gpg {
  KEYSER_VAULT_DIR='../tmp/test_cacert__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  res=`cacert domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem.gpg" ] || exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cacert__gpg) && echo 'OK' || echo 'KO'
fi
