#!/bin/bash

# set -e
cd `dirname "${BASH_SOURCE}"`
. ../lib/api.sh

function test_utils_domain {
  res=`utils_domain test.domain.com`
  [ $? != 0 ] && exit 1
  [ $res == 'test' ] || exit 1
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo -n "$0: "
  (test_utils_domain) && echo 'OK' || echo 'KO'
fi
