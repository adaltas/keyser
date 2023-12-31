#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_utils_write_sign_cnf {
  KEYSER_VAULT_DIR='../tmp/test_utils_write_sign_cnf'
  mkdir -p $KEYSER_VAULT_DIR
  utils_write_sign_cnf $KEYSER_VAULT_DIR/sign.cnf
  [ $? != 0 ] && exit 1
  cat $KEYSER_VAULT_DIR/sign.cnf | grep 'basicConstraints=critical,CA:TRUE,pathlen:1' > /dev/null
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_utils_write_sign_cnf) && echo 'OK' || echo 'KO'
fi
