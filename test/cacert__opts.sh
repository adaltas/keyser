#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  KEYSER_VAULT_DIR='../tmp/cacert__opts'
  KEYSER_GPG_MODE=
  KEYSER_GPG_PASSPHRASE=
  rm -rf $KEYSER_VAULT_DIR
  # Validate country option
  # res=`cert -c FR -e no-reply@domain -l P -o O domain.com test.domain.com`
  res=`cacert -e no-reply@domain -l P -o O domain.com test.domain.com`
  [[ $? == 1 ]] || exit 1
  echo "$res" | grep 'Country is missing from arguments.' > /dev/null
  # Validate email option
  res=`cacert -c FR -l P -o O domain.com test.domain.com`
  [[ $? == 1 ]] || exit 1
  echo "$res" | grep 'Email is missing from arguments.' > /dev/null
  # Validate location option
  res=`cacert -c FR -e no-reply@domain -o O domain.com test.domain.com`
  [[ $? == 1 ]] || exit 1
  echo "$res" | grep 'Location is missing from arguments.' > /dev/null
  # Validate organization option
  res=`cacert -c FR -e no-reply@domain -l P domain.com test.domain.com`
  [[ $? == 1 ]] || exit 1
  echo "$res" | grep 'Organization is missing from arguments.' > /dev/null
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
