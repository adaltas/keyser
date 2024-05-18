#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert__force_true {
  KEYSER_VAULT_DIR='../tmp/test_cacert__force_false'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Attempt to overwrite the certificate
  # cacert -f domain.com
  res=`cacert -f domain.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert__force_true) && echo 'OK' || echo 'KO'
fi
