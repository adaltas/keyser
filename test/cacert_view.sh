#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert_view {
  KEYSER_VAULT_DIR='../tmp/test_cacert_view'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
  echo "$res" | grep 'Subject: C=FR, O=Adaltas, L=Paris, CN=domain.com, emailAddress=no-reply@adaltas.com' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cacert_view) && echo 'OK' || echo 'KO'
fi
