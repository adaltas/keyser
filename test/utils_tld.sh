#!/bin/bash

cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test {
  res=`utils_tld test.domain.com`
  [[ $? != 0 ]] && exit 1
  [[ $res == 'domain.com' ]] || exit 1
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  echo -n "$0: "
  (test) && echo 'OK' || echo 'KO'
fi
