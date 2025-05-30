#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/utils_write_sign_cnf'
  mkdir -p $KEYSER_VAULT_DIR
  # Intermediate certificate
  utils_write_sign_cnf -i $KEYSER_VAULT_DIR/sign.cnf
  [[ $? != 0 ]] && return 1
  cat $KEYSER_VAULT_DIR/sign.cnf | grep 'basicConstraints=critical,CA:TRUE,pathlen:1' > /dev/null || return 1
  # Leaf certificate
  utils_write_sign_cnf $KEYSER_VAULT_DIR/sign.cnf
  [[ $? != 0 ]] && return 1
  cat $KEYSER_VAULT_DIR/sign.cnf | grep 'basicConstraints=critical,CA:FALSE,pathlen:1' > /dev/null || return 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  test && echo 'OK' || echo 'KO'
fi
