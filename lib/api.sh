#!/bin/bash
set -e

# Resources
# http://users.skynet.be/pascalbotte/art/server-cert.htm: ca serial and pks store

pwd=`dirname "${BASH_SOURCE}"`
# VAULT_DIR="${VAULT_DIR:-'../vault'}"
VAULT_DIR="${VAULT_DIR:-../out}"

help(){
  echo """
Usage:
  keyser <command>

Available Commands:
  ./keyser cacert <fqdn>
  ./keyser cacert_view <fqdn>
  ./keyser cert <fqdn>
  ./keyser cert_check <fqdn> [<ca_file>]
  ./keyser cert_check_from_file <fqdn_file> [<ca_file>]
  ./keyser cert_view <fqdn>
  ./keyser csr_create <fqdn>
  ./keyser csr_sign <fqdn>
  ./keyser csr_sign_from_file <fqdn>
  ./keyser csr_view <fqdn>

Example
  ./keyser cacert domain.com
  ./keyser cert test.domain.com
  ./keyser cert_view test.domain.com

"""
}

help_cacert(){
  echo """
Description
  Create a certificate authority.

Usage
  keyser cacert <fqdn>
"""
}
cacert(){
  tld=$1
  if [ -e $1 ]; then help_cacert; exit; fi
  tld_dir=$VAULT_DIR/$tld
  # Validation
  if [ -f "$tld_dir/ca.key.pem" ]; then  echo ''; echo '!!! cacert files already exists !!!'; echo ''; help; exit 1; fi
  # Prepare configuration template
  mkdir -p $tld_dir
  cp -rp $pwd/ca.cnf $tld_dir/ca.cnf
  sed -i "s|<commonName>|$tld|" $tld_dir/ca.cnf
  # RSA Private key (create "ca.key.pem")
  openssl genrsa -out $tld_dir/ca.key.pem 2048
  # Self-signed (with the key previously generated) root CA certificate (create "ca.cert.pem")
  # "/C=FR/ST=IDF/L=Paris/O=Adaltas/CN=adaltas.com/emailAddress=david@adaltas.com"
  openssl req -x509 -new -sha256 \
    -config $tld_dir/ca.cnf \
    -subj "/C=FR/O=ADALTAS/L=Paris/CN=$tld" \
    -key $tld_dir/ca.key.pem -days 7300 \
    -out $tld_dir/ca.cert.pem
  echo 'Certificate key created:' $tld_dir/ca.key.pem
  echo 'Certificate authority created:' $tld_dir/ca.cert.pem
}

help_cacert_view(){
  echo """
Description
  Print a certificate authority.

Usage
  keyser cacert_view <fqdn>
"""
}
cacert_view(){
  fqdn=$1
  if [ -e $fqdn ]; then help_cacert_view; exit 1; fi
  tld_dir=$VAULT_DIR/$fqdn
  openssl x509 -noout -text -fingerprint \
    -in $tld_dir/ca.cert.pem
}

help_cert(){
  echo """
Description
  Generate a certificate.

Usage
  keyser cert <fqdn>

Generate the certificate and private key for a give hostname. The command
combine the csr_create and csr_sign commands for conveniency.
"""
}
cert(){
  fqdn=$1
  if [ -e $fqdn ]; then help_cert; exit 1; fi
  csr_create $fqdn
  csr_sign $fqdn
}

help_cert_check(){
  echo """
Description
  Check a hostname certificate against the certificate authority.

Usage
  keyser cert_check <fqdn>

Internally, the command localize the certificate inside its store. Then, it call
the cert_check_from_file command.
"""
}
cert_check(){
  if [ -e $1 ]; then help_cert_check; exit 1; fi
  fqdn=$1
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  cert_file=$tld_dir/$hostname.cert.pem
  cert_check_from_file $cert_file
}

help_cert_check(){
  echo """
Description
  Check a hostname certificate against the certificate authority.

Usage
  keyser cert_check_from_file <fqdn_file> [<ca_file>]

Internally, the command localize the certificate inside its store. Then, it call
the cert_check_from_file command.
"""
}
cert_check_from_file(){
  cert_file=$1
  if [ ! -f $cert_file ]; then echo 'Certificate file does not exist'; exit 1; fi
  fqdn=`openssl x509 -noout -subject -in $cert_file | sed -n '/^subject/s/^.*CN\s*=\s*//p'`
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  ca_file=${2:-"$tld_dir/ca.cert.pem"}
  echo $ca_file
  echo $cert_file
  openssl verify \
    -CAfile $ca_file \
    $cert_file \
    2>/dev/null
  if [ $? == 0 ]; then
    echo 'Certificate is valid.'
  else
    echo 'Certificate is not valid.'
    exit 1
  fi
}

help_cert_view(){
  echo """
Description
  Print a certificate.

Usage
  keyser cert_view <fqdn>

Generate the certificate and private key for a give hostname. The command
combine the csr_create and csr_sign commands for conveniency.
"""
}
cert_view(){
  if [ -z "$1" ]; then help_cert_view; exit 1; fi
  fqdn=$1
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  #domain=`openssl x509 -noout -subject -in ca.cert.pem | sed -n '/^subject/s/^.*CN=//p'`
  #shortname=${fqdn%".$domain"}
  # shortname=`echo $1 | sed 's/\([[:alnum:]]\)\..*/\1/'`
  openssl x509 -text -fingerprint \
    -in $tld_dir/${hostname}.cert.pem
}

help_csr_create(){
  echo """
Description
  Create a certificate signing request

Usage
  keyser cert <fqdn>

Generate a the key and the certificate signing request.
"""
}
csr_create(){
  fqdn=$1
  if [ -e $fqdn ]; then help_csr_create; exit 1; fi
  # domain=`openssl x509 -noout -subject -in $VAULT_DIR/ca.cert.pem | sed -n '/^subject/s/^.*CN=//p'`
  # hostname=${fqdn%".$domain"}
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  if [ ! -f $tld_dir/ca.key.pem ]; then echo 'Run `./keyser cacert` first.'; exit 1; fi
  # to view the CSR: `openssl req -in toto.cert.csr -noout -text`
  # Sign the CSR (create "hadoop.cert.pem")
  openssl req -newkey rsa:2048 -sha256 -nodes \
    -out $tld_dir/${hostname}.cert.csr \
    -keyout $tld_dir/${hostname}.key.pem \
    -subj "/C=FR/O=ADALTAS.CLOUD/L=Paris/CN=${fqdn}" \
    2>/dev/null
  echo 'Key created in:' $tld_dir/${hostname}.key.csr
  echo 'CSR created in:' $tld_dir/${hostname}.cert.csr
}

csr_sign(){
  if [ -z "$1" ]; then help; exit 1; fi
  fqdn=$1
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  csr_file=$VAULT_DIR/$tld/$hostname.cert.csr
  csr_sign_from_file $csr_file
}

csr_sign_from_file(){
  csr_file=$1
  if [ ! -f $csr_file ]; then echo 'CSR file does not exist'; exit 1; fi
  fqdn=`openssl req -noout -subject -in  $csr_file | sed -n '/^subject/s/^.*CN\s*=\s*//p'`
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  # Copy the csr file into the vault directory unless already there
  if [ $csr_file != $tld_dir/${csr_file##*/} ]; then
    cp -rp $csr_file $tld_dir/${csr_file##*/}
  fi
  # Sign the CSR (create "${shortname}.cert.pem")
  openssl x509 -req -sha256 -days 7300 \
    -CA $tld_dir/ca.cert.pem -CAkey $tld_dir/ca.key.pem \
    -CAcreateserial -CAserial $tld_dir/ca.seq \
    -extfile $pwd/sign.cnf \
    -in $csr_file \
    -out $tld_dir/${hostname}.cert.pem \
    2>/dev/null
  echo 'Certificate created in:' $tld_dir/${hostname}.cert.pem
}

csr_view(){
  fqdn=$1
  if [ -z "$1" ]; then help; exit 1; fi
  tld=${fqdn#*.}
  hostname=${fqdn%%.*}
  tld_dir=$VAULT_DIR/$tld
  # domain=`openssl x509 -noout -subject -in $VAULT_DIR/ca.cert.pem | sed -n '/^subject/s/^.*CN=//p'`
  # shortname=${fqdn%".$domain"}
  openssl req -noout -text \
    -in $tld_dir/${hostname}.cert.csr
}
