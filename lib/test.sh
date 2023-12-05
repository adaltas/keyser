#!/bin/bash
set -e

cd `dirname "${BASH_SOURCE}"`

. api.sh

function test_cacert {
  VAULT_DIR='../tmp/test_cacert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  [ -f "$VAULT_DIR/domain.com/ca.cert.pem" ] || false
}

function test_cacert_view {
  VAULT_DIR='../tmp/test_cacert_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Validate certificate
  res=`cacert_view domain.com`
  echo $res | grep 'Certificate:' > /dev/null 
}

function test_cert {
  VAULT_DIR='../tmp/test_cert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  cert test.domain.com
  [ -f "$VAULT_DIR/domain.com/test.cert.pem" ] || false
}

function test_cert_check {
  VAULT_DIR='../tmp/test_cert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  cert test.domain.com
  # Validate certificate
  res=`cert_check test.domain.com`
  echo $res | grep 'Certificate is valid.' > /dev/null 
}

function test_cert_check_from_file {
  VAULT_DIR='../tmp/test_cert_check_from_file'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  cert test.domain.com
  # Validate certificate
  res=`cert_check_from_file "$VAULT_DIR/domain.com/test.cert.pem"`
  echo $res | grep 'Certificate is valid.' > /dev/null 
}

function test_cert_check_from_file_invalid {
  VAULT_DIR='../tmp/test_cert_check_from_file_invalid'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  cert test.domain.com
  # create an invalid certificate
  cacert invalid.com
  cp -rp "$VAULT_DIR/invalid.com/ca.cert.pem" "$VAULT_DIR/domain.com/ca.cert.pem"
  # Validate certificate
  res=`cert_check_from_file "$VAULT_DIR/domain.com/test.cert.pem"`
  echo $res | grep 'Certificate is not valid.' > /dev/null 
}

function test_cert_view {
  VAULT_DIR='../tmp/test_cert_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  cert test.domain.com
  res=`cert_view test.domain.com`
  echo $res | grep 'Certificate:' > /dev/null 
}

function test_csr_create {
  VAULT_DIR='../tmp/test_csr_create'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  csr_create test.domain.com
  [ -f "$VAULT_DIR/domain.com/test.cert.csr" ] || false
}

function test_csr_sign {
  VAULT_DIR='../tmp/test_csr_sign'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  csr_create test.domain.com
  csr_sign test.domain.com
  [ -f "$VAULT_DIR/domain.com/test.cert.pem" ] || false
}

function test_csr_sign_from_file {
  VAULT_DIR='../tmp/test_csr_sign_from_file'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  csr_create test.domain.com
  csr_sign_from_file "$VAULT_DIR/domain.com/test.cert.csr"
  [ -f "$VAULT_DIR/domain.com/test.cert.pem" ] || false
}

function test_csr_view {
  VAULT_DIR='../tmp/test_csr_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com
  # Create a certificate
  csr_create test.domain.com
  res=`csr_view test.domain.com`
  echo $res | grep 'Certificate Request:' > /dev/null 
}

tests="""
test_cacert
test_cacert_view
test_cert
test_cert_check
test_cert_check_from_file
test_cert_check_from_file_invalid
test_cert_view
test_csr_create
test_csr_sign
test_csr_sign_from_file
test_csr_view
"""

for test in $tests; do
  if ! [[ $test = \#* ]]; then
    # echo ''; echo - $test \(skipped\)
    echo ''; echo - $test
    (! $test ) && echo 'KO' && exit 1
  fi
done
echo ''
echo 'All tests passed.'
