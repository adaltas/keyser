#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert {
  KEYSER_VAULT_DIR='../tmp/test_cacert'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  res=`cacert domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ] || exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cacert) && echo 'OK' || echo 'KO'
fi
