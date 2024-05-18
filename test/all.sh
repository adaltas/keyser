#!/bin/bash
set -e

cd `dirname "${BASH_SOURCE}"`

for test in `ls *`; do
  if [[ $test != "all.sh" ]]; then
    printf "%-50s" $test
    . $test
    fn=test_`basename $test .sh`
    # 
    ( $fn ) && echo 'OK' || (echo 'KO' && exit 1)
  fi
done
