#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_write_ca_cnf'
  mkdir -p $KEYSER_VAULT_DIR
  utils_write_ca_cnf $KEYSER_VAULT_DIR/ca.cnf
  [[ $? != 0 ]] && return 1
  cat $KEYSER_VAULT_DIR/ca.cnf | grep 'default_ca    = CA_default' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
