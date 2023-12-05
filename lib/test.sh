#!/bin/bash
set -e

cd `dirname "${BASH_SOURCE}"`

. api.sh

function test_cacert {
  KEYSER_VAULT_DIR='../tmp/test_cacert'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  res=`cacert domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ] || exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

function test_cacert__gpg {
  KEYSER_VAULT_DIR='../tmp/test_cacert__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  . api.sh
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  res=`cacert domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem" ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain/key.pem.gpg" ] || exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

function test_cacert__subject_default {
  KEYSER_VAULT_DIR='../tmp/test_cacert__subject'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | grep 'subject=C=FR, O=Adaltas, L=Paris, CN=domain.com, emailAddress=no-reply@adaltas.com' > /dev/null
}

function test_cacert__subject_custom {
  KEYSER_VAULT_DIR='../tmp/test_cacert__subject'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert -c PL -o "My Domain" -l Warsawa -e no-reply@domain.com domain.com > /dev/null
  res=`openssl x509 -noout -subject -in $KEYSER_VAULT_DIR/com.domain/cert.pem`
  echo "$res" | grep 'subject=C=PL, O=My Domain, L=Warsawa, CN=domain.com, emailAddress=no-reply@domain.com' > /dev/null
}

function test_cacert__force_false {
  KEYSER_VAULT_DIR='../tmp/test_cacert__force_false'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Attempt to overwrite the certificate
  res=`cacert domain.com`
  [ $? != 1 ] && exit 1
  echo "$res" | grep 'CA certificate files already exists.' > /dev/null
}

function test_cacert__force_true {
  KEYSER_VAULT_DIR='../tmp/test_cacert__force_false'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Attempt to overwrite the certificate
  # cacert -f domain.com
  res=`cacert -f domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate key created:' > /dev/null
  echo "$res" | grep 'Certificate authority created:' > /dev/null
}

function test_cacert_view {
  KEYSER_VAULT_DIR='../tmp/test_cacert_view'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
  echo "$res" | grep 'Subject: C=FR, O=Adaltas, L=Paris, CN=domain.com, emailAddress=no-reply@adaltas.com' > /dev/null
}

function test_cacert_view__gpg {
  KEYSER_VAULT_DIR='../tmp/test_cacert_view__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Validate certificate
  res=`cacert_view domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate:' > /dev/null
  echo "$res" | grep 'Subject: C=FR, O=Adaltas, L=Paris, CN=domain.com, emailAddress=no-reply@adaltas.com' > /dev/null
}

function test_cert {
  KEYSER_VAULT_DIR='../tmp/test_cert'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  res=`cert test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/ca.crt" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_cert__with_ca_fqdn {
  KEYSER_VAULT_DIR='../tmp/test_cert'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain-1.com > /dev/null
  # Create a certificate
  res=`cert test.domain-2.com domain-1.com`
  # Validate execution
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain-2.test/ca.crt" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain-2.test/cert.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain-2.test/key.pem" ] || exit 1
  # Make sure the ca.crt is correctly generated
  cacertin=`openssl x509 -noout -fingerprint -in $KEYSER_VAULT_DIR/com.domain-1/cert.pem`
  cacertout=`openssl x509 -noout -fingerprint -in $KEYSER_VAULT_DIR/com.domain-2.test/ca.crt`
  [[ $cacertin == $cacertout ]] || exit 1
  cert_check_from_file $KEYSER_VAULT_DIR/com.domain-2.test/cert.pem $KEYSER_VAULT_DIR/com.domain-2.test/ca.crt > /dev/null
  [ $? != 0 ] && exit 1
  # Validate output
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

test_cert__intermediate() {
  KEYSER_VAULT_DIR='../tmp/test_cert__intermediate'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain-1.com >/dev/null
  # Create an intermediate certificates
  cert domain-2.com domain-1.com >/dev/null
  cert domain-3.com domain-2.com >/dev/null
  # # Create a leaf certificate
  cert domain-4.com domain-3.com >/dev/null
  # Certificate validation
  res=`cert_check domain-4.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

function test_cert_check {
  KEYSER_VAULT_DIR='../tmp/test_cert'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Validate certificate
  res=`cert_check test.domain.com`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

function test_cert_check_from_file__no_ca_file {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__no_ca_file'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Validate certificate
  res=`cert_check_from_file $KEYSER_VAULT_DIR/com.domain.test/cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

function test_cert_check_from_file__with_ca_file {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__with_ca_file'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # Move parent certificate
  mv $KEYSER_VAULT_DIR/com.domain/cert.pem $KEYSER_VAULT_DIR/parent.cert.pem
  # Validate certificate
  res=`cert_check_from_file $KEYSER_VAULT_DIR/com.domain.test/cert.pem $KEYSER_VAULT_DIR/parent.cert.pem`
  [ $? != 0 ] && exit 1
  echo "$res" | grep 'Certificate is valid.' > /dev/null
}

function test_cert_check_from_file__invalid {
  KEYSER_VAULT_DIR='../tmp/test_cert_check_from_file__invalid'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com > /dev/null
  # Create a certificate
  cert test.domain.com > /dev/null
  # create an invalid certificate
  cacert invalid.com > /dev/null
  cp -rp "$KEYSER_VAULT_DIR/com.invalid/cert.pem" "$KEYSER_VAULT_DIR/com.domain/cert.pem"
  # Validate certificate
  res=`cert_check_from_file "$KEYSER_VAULT_DIR/com.domain.test/cert.pem"`
  [ $? != 1 ] && exit 1
  echo "$res" | grep 'Certificate is not valid.' > /dev/null
}

function test_cert_view {
  KEYSER_VAULT_DIR='../tmp/test_cert_view'
  rm -rf $KEYSER_VAULT_DIR
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
  KEYSER_VAULT_DIR='../tmp/test_csr_create'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  res=`csr_create test.domain.com`
  [ $? != 0 ] && (echo $res && exit 1)
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.csr" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
}

function test_csr_create__gpg { # _discover_domain
  KEYSER_VAULT_DIR='../tmp/test_csr_create__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  res=`csr_create test.domain.com`
  [ $? != 0 ] && (echo $res && exit 1)
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem" ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/key.pem.gpg" ] || exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.csr" ] || exit 1
  echo "$res" | grep 'Key created in:' > /dev/null
  echo "$res" | grep 'CSR created in:' > /dev/null
}

function test_csr_sign { # _discover_domain
  KEYSER_VAULT_DIR='../tmp/test_csr_sign'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_csr_sign__gpg {
  KEYSER_VAULT_DIR='../tmp/test_csr_sign__gpg'
  KEYSER_GPG_MODE=symmetric
  KEYSER_GPG_PASSPHRASE=secret
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign test.domain.com`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  # [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem.gpg" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_csr_sign_from_file {
  KEYSER_VAULT_DIR='../tmp/test_csr_sign_from_file'
  rm -rf $KEYSER_VAULT_DIR
  # Generate a certificate authority
  cacert domain.com >/dev/null
  # Create a certificate
  csr_create test.domain.com >/dev/null
  # Sign the certificate
  res=`csr_sign_from_file "$KEYSER_VAULT_DIR/com.domain.test/cert.csr"`
  [ $? != 0 ] && exit 1
  [ -f "$KEYSER_VAULT_DIR/com.domain.test/cert.pem" ] || exit 1
  echo "$res" | grep 'Certificate created in:' > /dev/null
}

function test_csr_view {
  KEYSER_VAULT_DIR='../tmp/test_csr_view'
  rm -rf $KEYSER_VAULT_DIR
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
test_cacert__gpg
test_cacert__subject_default
test_cacert__subject_custom
test_cacert__force_false
test_cacert__force_true
test_cacert_view
test_cacert_view__gpg
test_cert
test_cert__with_ca_fqdn
test_cert__intermediate
test_cert_check
test_cert_check_from_file__no_ca_file
test_cert_check_from_file__with_ca_file
test_cert_check_from_file__invalid
test_cert_view
test_csr_create
test_csr_create__gpg
test_csr_sign
test_csr_sign__gpg
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
