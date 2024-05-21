#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert_view__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
  echo "$res" | grep 'Subject: C=FR, O=O, L=P, CN=domain.com, emailAddress=no-reply@domain' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
