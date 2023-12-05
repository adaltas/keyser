
# Keyser - encryption key and certificate management

Keyser is a single file bash script used to generate and manage SSL certificates.

## Features

- Generate, store, view certificates
- Intermediate certificates
- GPG key encryption support
- Documented
- Test coverage

## Installation

Download the script and make it executable.

```sh
curl -O https://raw.githubusercontent.com/adaltas/keyser/main/keyser
chmod u+x keyser
./keyser
```

## Usage

Run the `./keyser` command without any argument to print detailed information.

```text
Usage:
  keyser <command>

Available Commands:
  keyser cacert <fqdn>
  keyser cacert_view <fqdn>
  keyser cert <fqdn> [<ca_fqdn>]
  keyser cert_check <fqdn> [<cacert_file>]
  keyser cert_check_from_file <cert_file> [<cacert_file>]
  keyser cert_view <fqdn>
  keyser csr_create <fqdn>
  keyser csr_sign <fqdn> [<ca_fqdn>]
  keyser csr_sign_from_file <csr_file> [<ca_fqdn>]
  keyser csr_view <fqdn>

Environment variables:
  KEYSER_VAULT_DIR       Keys directory storage location.
  KEYSER_GPG_MODE        Use symmetric or leave empty for no encryption.
  KEYSER_GPG_PASSPHRASE  Passphrase used for GPG encryption.

Example to view a certificate:
  keyser cacert domain.com
  keyser cert test.domain.com
  keyser cert_view test.domain.com

Example with intermediate certificate:
  keyser cacert domain-1.com
  keyser cert domain-2.com domain-1.com
  keyser cert domain-3.com domain-2.com
  keyser cert_check_from_file test.domain.com ./vault/com/domain-3/cert.pem ./vault/com/domain-3/ca.crt

Example with symetric encryption:
  export KEYSER_GPG_MODE=symmetric
  export KEYSER_GPG_PASSPHRASE=secret
  keyser cacert domain-1.com
```

## Tests

The test suite is launched with `./test/all.sh`. Run `./test/<name>.sh` to execute a single test.
