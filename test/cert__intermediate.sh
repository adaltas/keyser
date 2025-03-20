#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

test() {
  KEYSER_VAULT_DIR='../tmp/cert__intermediate'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain-1.com >/dev/null
  # Create an intermediate certificates
  cert -i domain-2.com domain-1.com >/dev/null
  cert -i domain-3.com domain-2.com >/dev/null
  # # Create a leaf certificate
  cert domain-4.com domain-3.com >/dev/null
  # Certificate validation
  res=`cert_check domain-4.com`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
