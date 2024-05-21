#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

cert__invalid_ca() {
  KEYSER_VAULT_DIR='../tmp/cert__invalid_ca'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Create a certificates
  res=`cert test.domain.com domain`
  [[ $? != 1 ]] && exit 1
  echo "$res" | grep 'Parent FQDN is not registered in the vault repository, use `cacert` to generate a self-signed certiciate.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (cert__invalid_ca) && echo 'OK' || echo 'KO'
fi
