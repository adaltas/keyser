#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

test() {
  KEYSER_VAULT_DIR='../tmp/cert__invalid_ca'
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR && init >/dev/null
  # Create a certificates
  res=$(cert test.domain.com domain)
  [[ $? != 1 ]] && return 1
  echo "$res" | grep "Parent FQDN is not registered in the vault repository, use \`cacert\` to generate a self-signed certiciate." > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
