#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_vault_created__false'
  rm -rf $KEYSER_VAULT_DIR
  # Validation
  res=$(utils_vault_created 2>&1)
  [[ $? == 1 ]] || return 1
  [[ $res == "Vault not initialized, run \`keyser init\` first." ]] || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
