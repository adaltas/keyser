#!/bin/bash
set -e

cd `dirname "${BASH_SOURCE}"`

. api.sh

function test_cacert {
  VAULT_DIR='../tmp/test_cacert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  res=`cacert domain.com`
  [ -f "$VAULT_DIR/com.domain/cert.pem" ] || exit 1
  [ -f "$VAULT_DIR/com.domain/key.pem" ] || exit 1
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null 
  echo "$res" | grep 'Certificate authority created:' > /dev/null 
}

function test_cacert_view {
  VAULT_DIR='../tmp/test_cacert_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
  echo "$res" | grep 'Subject: C = FR, O = ADALTAS, L = Paris, CN = domain.com' > /dev/null
}

function test_cert {
  VAULT_DIR='../tmp/test_cert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  res=`cert test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  [ -f "$VAULT_DIR/com.domain.test/key.pem" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_cert_check {
  VAULT_DIR='../tmp/test_cert'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Validate certificate
  res=`cert_check test.domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null 
}

function test_cert_check_from_file_no_ca_file {
  VAULT_DIR='../tmp/test_cert_check_from_file_no_ca_file'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Validate certificate
  res=`cert_check_from_file $VAULT_DIR/com.domain.test/cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null 
}

function test_cert_check_from_file_with_ca_file {
  VAULT_DIR='../tmp/test_cert_check_from_file_with_ca_file'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Move parent certificate
  mv $VAULT_DIR/com.domain/cert.pem $VAULT_DIR/parent.cert.pem
  # Validate certificate
  res=`cert_check_from_file $VAULT_DIR/com.domain.test/cert.pem $VAULT_DIR/parent.cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null 
}

function test_cert_check_from_file_invalid {
  VAULT_DIR='../tmp/test_cert_check_from_file_invalid'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # create an invalid certificate
  cacert invalid.com > /dev/null
  cp -rp "$VAULT_DIR/com.invalid/cert.pem" "$VAULT_DIR/com.domain/cert.pem"
  # Validate certificate
  res=`cert_check_from_file "$VAULT_DIR/com.domain.test/cert.pem"`
  [ $? != 1 ] && exit 1
  echo "$res" | grep 'Certificate is not valid.' > /dev/null 
}

function test_cert_view {
  VAULT_DIR='../tmp/test_cert_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # View a certificate
  res=`cert_view test.domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null 
}

function test_csr_create { # _discover_domain
  VAULT_DIR='../tmp/test_csr_create'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  res=`csr_create test.domain.com`
  [ $? != 0 ] && (echo $res && exit 1)
  [ -f "$VAULT_DIR/com.domain.test/key.pem" ] || exit 1
  [ -f "$VAULT_DIR/com.domain.test/cert.csr" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null 
  echo "$res" | grep 'CSR created in:' > /dev/null 
}

function test_csr_sign { # _discover_domain
  VAULT_DIR='../tmp/test_csr_sign'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_csr_sign_from_file {
  VAULT_DIR='../tmp/test_csr_sign_from_file'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign_from_file "$VAULT_DIR/com.domain.test/cert.csr"`
  [ $? != 0 ] && exit 1
  [ -f "$VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_csr_view {
  VAULT_DIR='../tmp/test_csr_view'
  rm -rf $VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # View the certificate
  res=`csr_view test.domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate Request:' > /dev/null 
}

function test_utils_reverse {
  res=`utils_reverse test.domain.com`
  [ $? != 0 ] && exit 1
  [ $res == 'com.domain.test' ] || exit 1
}

function test_utils_tld {
  res=`utils_tld test.domain.com`
  [ $? != 0 ] && exit 1
  [ $res == 'domain.com' ] || exit 1
}

function test_utils_domain {
  res=`utils_domain test.domain.com`
  [ $? != 0 ] && exit 1
  [ $res == 'test' ] || exit 1
}

tests="""
test_cacert
test_cacert_view
test_cert
test_cert_check
test_cert_check_from_file_no_ca_file
test_cert_check_from_file_with_ca_file
test_cert_check_from_file_invalid
test_cert_view
test_csr_create
test_csr_sign
test_csr_sign_from_file
test_csr_view
test_utils_reverse
test_utils_tld
test_utils_domain
"""

for test in $tests; do
  if ! [[ $test = \#* ]]; then
    # echo ''; echo - $test \(skipped\)
    echo - $test
    ( $test ) || (echo 'KO' && exit 1)
  fi
done
echo ''
echo 'All tests passed.'
