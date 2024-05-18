#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_cacert_list__with_ca {
  KEYSER_VAULT_DIR='../tmp/test_cacert_list__with_ca'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c FR -e no-reply@domain -l P -o O domain-1.com >/dev/null
  # Create an intermediate certificates
  cert domain-2.com domain-1.com >/dev/null
  cert domain-3.com domain-2.com >/dev/null
  # # Create a leaf certificate
  cert domain-4.com domain-3.com >/dev/null
  # List all certificates from the vault
  res=`cacert_list`
  [[ $? != 0 ]] && exit 1
  echo "$res" | grep 'domain-1.com' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_cacert_list__with_ca) && echo 'OK' || echo 'KO'
fi
