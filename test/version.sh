#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_version {
  # Generate a certificate authority
  res=`version | grep -e '\d\d*\.\d\d*\.\d\d*'`
  [[ $? != 0 ]] && exit 1
  true
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test_version) && echo 'OK' || echo 'KO'
fi
