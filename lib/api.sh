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
  keyser cacert <fqdn>
  keyser cacert_view <fqdn>
  keyser cert <fqdn>
  keyser cert_check <fqdn> [<ca_file>]
  keyser cert_check_from_file <cert_file> [<ca_file>]
  keyser cert_view <fqdn>
  keyser csr_create <fqdn>
  keyser csr_sign <fqdn> [<ca_fqdn>]
  keyser csr_sign_from_file <csr_file> [<ca_fqdn>]
  keyser csr_view <fqdn>

Example
  keyser cacert domain.com
  keyser cert test.domain.com
  keyser cert_view test.domain.com

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
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_cacert; exit 1; fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  # Validation
  if [ -f "$fqdn_dir/ca.key.pem" ]; then  echo ''; echo '!!! cacert files already exists !!!'; echo ''; help; exit 1; fi
  # Prepare configuration template
  mkdir -m 700 -p $fqdn_dir
  cp -rp $pwd/ca.cnf $fqdn_dir/ca.cnf
  sed -i "s|<commonName>|$fqdn|" $fqdn_dir/ca.cnf
  # RSA Private key (create "ca.key.pem")
  openssl genrsa -out $fqdn_dir/key.pem 2048
  # Self-signed (with the key previously generated) root CA certificate (create "ca.cert.pem")
  # man: The req command primarily creates and processes certificate requests in PKCS#10 format.
  # "/C=FR/ST=IDF/L=Paris/O=Adaltas/CN=adaltas.com/emailAddress=david@adaltas.com"
  openssl req -x509 -new -sha256 \
    -config $fqdn_dir/ca.cnf \
    -subj "/C=FR/O=ADALTAS/L=Paris/CN=$fqdn" \
    -key $fqdn_dir/key.pem -days 7300 \
    -out $fqdn_dir/cert.pem
  echo 'Certificate key created:' $fqdn_dir/key.pem
  echo 'Certificate authority created:' $fqdn_dir/cert.pem
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
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_cacert_view; exit 1; fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  openssl x509 -noout -text -fingerprint \
    -in $fqdn_dir/cert.pem
}

help_cert(){
  echo """
Description
  Generate a certificate.

Usage
  keyser cert <fqdn>

Generate the certificate and private key for a give hostname. The command combine the csr_create and csr_sign commands for conveniency.
"""
}
cert(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_cert; exit 1; fi
  csr_create $fqdn
  csr_sign $fqdn
}

help_cert_check(){
  echo """
Description
  Check a hostname certificate against the certificate authority.

Usage
  keyser cert_check <fqdn> [<ca_file>]

Internally, the command localize the certificate inside its store. Then, it call the cert_check_from_file command.
"""
}
cert_check(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_cert_check; exit 1; fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  cert_file=$fqdn_dir/cert.pem
  cert_check_from_file $cert_file $2
}

help_cert_check_from_file(){
  echo """
Description
  Check a hostname certificate against the certificate authority.

Usage
  keyser cert_check_from_file <cert_file> [<ca_file>]

Internally, the command localize the certificate inside its store. Then, it call
the cert_check_from_file command.
"""
}
cert_check_from_file(){
  cert_file=$1
  if [ ! -n "$cert_file" ]; then echo 'Certificate file path is missing from arguments.'; help_cert_check_from_file; exit 1; fi
  if [ ! -f $cert_file ]; then echo "Certificate file does not exist: \"$cert_file\"."; exit 1; fi
  ca_file=$2
  echo ca_file_before: $ca_file
  if [ ! -n "$ca_file" ]; then 
    fqdn=`openssl req -noout -subject -in  $csr_file | sed -n '/^subject/s/^.*CN\s*=\s*//p'`;
    ca_fqdn=${fqdn#*.}
    ca_fqdn_dir=$VAULT_DIR/$(utils_reverse $ca_fqdn)
    ca_file=$ca_fqdn_dir/cert.pem
  fi
  echo ca_file_after: $ca_file
  echo cert_file: $cert_file
  openssl verify \
    -CAfile $ca_file \
    $cert_file \
    >/dev/null \
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

Print the detailed information of a Certificate Signing Request (CSR) file.
"""
}
cert_view(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_cert_view; exit 1; fi
  # tld=${fqdn#*.}
  # hostname=${fqdn%%.*}
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  #domain=`openssl x509 -noout -subject -in ca.cert.pem | sed -n '/^subject/s/^.*CN=//p'`
  #shortname=${fqdn%".$domain"}
  # shortname=`echo $1 | sed 's/\([[:alnum:]]\)\..*/\1/'`
  openssl x509 -text -fingerprint \
    -in $fqdn_dir/cert.pem
}

help_csr_create(){
  echo """
Description
  Create a certificate signing request.

Usage
  keyser csr_create <fqdn>

Generate a key and its certificate signing request.
"""
}
csr_create(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_csr_create; exit 1; fi
  # domain=`openssl x509 -noout -subject -in $VAULT_DIR/ca.cert.pem | sed -n '/^subject/s/^.*CN=//p'`
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  # to view the CSR: `openssl req -in toto.cert.csr -noout -text`
  # Sign the CSR (create "hadoop.cert.pem")
  mkdir -m 700 -p $fqdn_dir
  openssl req -newkey rsa:2048 -sha256 -nodes \
    -out $fqdn_dir/cert.csr \
    -keyout $fqdn_dir/key.pem \
    -subj "/C=FR/O=ADALTAS.CLOUD/L=Paris/CN=${fqdn}" \
    2>/dev/null
  [ $? != 0 ] && exit 1
  echo 'Key created in:' $fqdn_dir/key.pem
  echo 'CSR created in:' $fqdn_dir/cert.csr
}

help_csr_sign(){
  echo """
Description
  Sign a CSR givent its path.

Usage
  keyser csr_sign <fqdn> [<ca_fqdn>]

Generate a certificate signing request (CSR) for a managed FQDN. Internally, it calls the "csr_sign_from_file" command.
"""
}
csr_sign(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_csr_sign; exit 1; fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  csr_sign_from_file $fqdn_dir/cert.csr $2
}

help_csr_sign_from_file(){
  echo """
Description
  Sign a CSR givent its path.

Usage
  keyser csr_sign_from_file <csr_file> [<ca_fqdn>]

Generate a certificate signing request (CSR) for a given file. The Certificate Authority FQDN is optionnal. When not provided, it is extracted from the CSR subject.
"""
}
csr_sign_from_file(){
  csr_file=$1
  if [ ! -f $csr_file ]; then echo "CSR file does not exist: \"$csr_file\"."; help_csr_sign_from_file; exit 1; fi
  fqdn=`openssl req -noout -subject -in  $csr_file | sed -n '/^subject/s/^.*CN\s*=\s*//p'`;
  ca_fqdn=$2
  if [ -e $ca_fqdn ]; then 
    ca_fqdn=${fqdn#*.}
  fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  ca_fqdn_dir=$VAULT_DIR/$(utils_reverse $ca_fqdn)
  if [ $csr_file != "$fqdn_dir/${csr_file##*/}" ]; then
    cp -rp $csr_file $fqdn_dir/${csr_file##*/}
  fi
  # Sign the CSR
  openssl x509 -req -sha256 -days 7300 \
    -CA $ca_fqdn_dir/cert.pem -CAkey $ca_fqdn_dir/key.pem \
    -CAcreateserial -CAserial $ca_fqdn_dir/ca.seq \
    -extfile $pwd/sign.cnf \
    -in $csr_file \
    -out $fqdn_dir/cert.pem \
    2>/dev/null
  echo 'Certificate created in:' $fqdn_dir/cert.pem
}

help_csr_view(){
  echo """
Description
  Print a CSR.

Usage
  keyser csr_view <fqdn>

Print the detailed information of a Certificate Signing Request (CSR) stored inside the vault.
"""
}
csr_view(){
  fqdn=$1
  if [ ! -n "$fqdn" ]; then echo 'FQDN is missing from arguments.'; help_csr_view; exit 1; fi
  fqdn_dir=$VAULT_DIR/$(utils_reverse $fqdn)
  if [ ! -f "$fqdn_dir/cert.csr" ]; then echo "CSR file for domain \"$fqdn\" does not exist."; help_csr_view; exit 1; fi
  openssl req -noout -text \
    -in $fqdn_dir/cert.csr
}

utils_reverse(){
  IFS=. read -ra line <<< "$1"
  let x=${#line[@]}-1;
  while [ "$x" -ge 0 ]; do
    echo -n "${line[$x]}";
    [ $x != 0 ] && echo -n '.';
    let x--;
    echo -n ''
  done
}

utils_tld(){
  fqdn=$1
  echo -n ${fqdn#*.}
}

utils_domain(){
  fqdn=$1
  echo -n ${fqdn%%.*}
}
