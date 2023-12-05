#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../lib/api.sh

test_cert__intermediate() {
  KEYSER_VAULT_DIR='../tmp/test_cert__intermediate'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain-1.com >/dev/null
  # Create an intermediate certificates
  cert domain-2.com domain-1.com >/dev/null
  cert domain-3.com domain-2.com >/dev/null
  # # Create a leaf certificate
  cert domain-4.com domain-3.com >/dev/null
  # Certificate validation
  res=`cert_check domain-4.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_cert__intermediate) && echo 'OK' || echo 'KO'
fi
