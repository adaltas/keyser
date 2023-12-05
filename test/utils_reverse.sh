#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../keyser

function test_utils_reverse {
  res=`utils_reverse test.domain.com`
  [ $? != 0 ] && exit 1
  [ $res == 'com.domain.test' ] || exit 1
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_utils_reverse) && echo 'OK' || echo 'KO'
fi
