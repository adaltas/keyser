# Keyser - encryption key and certificate management

Keyser is a single file bash script used to generate and manage SSL certificates.

## Features

- Generate, store, view certificates
- Intermediate certificates
- GPG key encryption support
- Documented
- Test coverage

## Installation

Keyser is a single Bash script with no external dependency. You can [download the latest version](https://raw.githubusercontent.com/adaltas/keyser/main/keyser) from its GitHub repository.

### Quick installation

The recommandation is to install keyser inside the `~/.keyser` folder.

GPG encryption is activated with the `KEYSER_GPG_PASSPHRASE` variable. Don't declare the variable or set it to an empty value to disable GPG encryption of certificate keys.

```bash
mkdir -p ~/.keyser/bin
curl -o ~/.keyser/bin/keyser -L https://bit.ly/adaltas-keyser
chmod u+x ~/.keyser/bin/keyser
echo 'PATH="$HOME/.keyser/bin:$PATH"' >> ~/.profile
echo "export KEYSER_VAULT_DIR=~/.keyser/vault" >> ~/.profile
# Change <secret> with your own value
echo "export KEYSER_GPG_PASSPHRASE=<secret>" >> ~/.profile
. ~/.profile
keyser
```

### Detailed installation

Keyser may be downloaded locally and made executable.

```bash
curl -o keyser -L https://bit.ly/adaltas-keyser
chmod u+x keyser
./keyser
```

Alternatively, the following command downloads and instantly executes Keyser to print its current version.

```bash
bash \
  <(curl -L -s https://bit.ly/adaltas-keyser) \
  version
```

To enable Keyser on your system, add its downloaded directory to your path and set the `KEYSER_VAULT_DIR` environment variable to an appropriate location. It default to the `./vault` directory.

The example expect the keyser script to be downloaded inside a `~/projects/keyser/bin` directory and a vault located inside a `~/project/keyser/vault` directory.

```bash
mkdir -p ~/projects
export PATH=~/projects/keyser:$PATH
export KEYSER_VAULT_DIR=~/project/keyser/vault
```

Additionnally, export the `KEYSER_GPG_PASSPHRASE` to enable GPG authentication of certificate keys.

```bash
export KEYSER_GPG_PASSPHRASE=<secret>
```

## Upgrading

To upgrade Keyser to its latest version, download the script again.

```bash
curl -o ~/.keyser/bin/keyser -L https://bit.ly/adaltas-keyser
```

## Usage

Run the `./keyser` command without any argument to print detailed information.

```text
Usage
  keyser <command>

Available Commands
  cacert                 Create a certificate authority.
  cacert_list            List the certificate authorities registered in the vault repository.
  cacert_view            Print a certificate authority.
  cert                   Generate a certificate.
  cert_check             Check a hostname certificate against the certificate authority.
  cert_check_from_file   Check a certificate against the certificate authority and its key.
  cert_export            Export a certificate and its private key into a target directory.
  cert_list              List the certificates registered in the vault repository.
  cert_view              Print a certificate.
  csr_create             Create a certificate signing request.
  csr_sign               Sign a CSR givent its path.
  csr_sign_from_file     Sign a CSR given its path.
  csr_view               Print a CSR.
  help                   Print the Keyser help.
  version                Print the Keyser version.

Environment variables
  KEYSER_VAULT_DIR       Keys directory storage location.
  KEYSER_GPG_MODE        GPG encryption mode, only "symmetric" is supported.
  KEYSER_GPG_PASSPHRASE  Passphrase used for GPG encryption or leave empty for no encryption.

Example to view a certificate
  keyser cacert domain.com
  keyser cert test.domain.com
  keyser cert_view test.domain.com

Example with intermediate certificate
  keyser cacert domain-1.com
  keyser cert domain-2.com domain-1.com
  keyser cert domain-3.com domain-2.com
  keyser cert_check_from_file test.domain.com ./vault/com/domain-3/cert.pem ./vault/com/domain-3/ca.crt

Example with symetric encryption
  export KEYSER_GPG_PASSPHRASE=secret
  keyser cacert domain-1.com
```

## Tutorial

This is an opinionated example on how to use Keyser. It uses a vault stored inside the `/tmp/keyser-tutorial` vault folder with keys crypted with GPG.

Run `keyser` to list the script available command. At any time in this tutorial, you can learn more about a single command with the `-h` option. It prints the command's description, option and usage. For example, run `keyser cacert help` to get help with the `cacert` command.

Two environment variables are used to control the new vault location and to activate GPG encryption.

```bash
export KEYSER_GPG_PASSPHRASE=secret
export KEYSER_VAULT_DIR=/tmp/keyser-tutorial
```

The turial start by creating a self-signed certificate authority for the `domain.com` domain. From there, a certificate for the intermediate domain `app.domain.com` is created. It is used to generate leaf certificate for the `www.app.domain.com` and `api.app.domain.com` domains.

Finally, a simple web application is started for testing purpose using Docker.

Create a self-signed certificate for `domain.com`.

```bash
keyser cacert \
  -c FR \
  -e no-reply@localhost \
  -l "My Computer" \
  -o Adaltas \
  domain.com
```

The command output is:

```text
Certificate authority created: /tmp/keyser-tutorial/com.domain/cert.pem
Certificate key created: /tmp/keyser-tutorial/com.domain/key.pem.gpg
```

The list of certificate authorities registered in the vault folder is obtained with the `keyser cacert_list` command.

Create an intermediate certificate for `app.domain.com` using the `-i` option. In this example, the second argument `domain.com` is optional. When undefined, it is derived from the `app.domain.com` parent domain.

```bash
keyser cert -i \
  app.domain.com \
  domain.com
```

The command output is:

```text
Key created in: /tmp/keyser-tutorial/com.domain.app/key.pem.gpg
CSR created in: /tmp/keyser-tutorial/com.domain.app/cert.csr
Certificate authority in: /tmp/keyser-tutorial/com.domain.app/ca.crt
Certificate created in: /tmp/keyser-tutorial/com.domain.app/cert.pem
```

Two leaf certificates are now created.

A single command is used to generate the first private key and public certificate. The command is voluntarily minimalist. Its configuration properties are derived from the parent certificates. Internally, the Certificate Signing Request (CSR) is automatically generated. The CSR is signed with the intermediate certificate created earlier.

The `-d` option indicates the certificate Subject Alternative Name (SAN). It is required to enable certificate recognition by web browsers.

Certificate are generated with an 825 days validity period. This is required by Safari and IOS environments for the certificate to be considered valid.

```bash
keyser cert \
  -d www.app.domain.com \
  www.app.domain.com
```

The second leaf certificate illustrate a more complete scenaria using configuration parameters and the generation of a CSR file.

```bash
keyser csr_create \
  -c FR \
  -d api.app.domain.com \
  -e no-reply@domain \
  -l Paris \
  -o Adaltas \
  api.app.domain.com
```

The location of the generated CSR is printed to stdout.

```text
Key created in: /tmp/keyser-tutorial/com.domain.test.api/key.pem.gpg
CSR created in: /tmp/keyser-tutorial/com.domain.test.api/cert.csr
```

To sign the certificate, you can use `keyser csr_sign`. In the event that someone provides you with a externally generated CSR, use `keyser src_sign_from_file`.

```bash
keyser csr_sign_from_file \
  -d api.app.domain.com \
  /tmp/keyser-tutorial/com.domain.app.api/cert.csr
```

Note, the `-d api.app.domain.com` shouldn't be necessary since it was already present inside the CSR file. We didn't yet found the time to investigate how to propagate its value to the certificate.

The `keyser cert_view` command print the certificate detailed information.

```bash
keyser cert_view \
  api.app.domain.com
```

Export the certificate into your project directory.

```bash
keyser cert_export \
  -c \
  www.app.domain.com \
  ./exports
```

```bash
# Create a Caddy configuration file with the private key and certificate
cat <<-EOF>./Caddyfile
	:443 {
    file_server browse {
      root /usr/share/caddy
    }
	  tls /certs/com.domain.app.www.cert.pem /certs/com.domain.app.www.key.pem
	}
	EOF
# Place a welcoming file
cat <<-EOF>./index.html
	<body>Hello Keyser!</body>
	EOF
# Start the Caddy web server with Docker
docker run -d --cap-add=NET_ADMIN -p 8443:443 \
  -v ./index.html:/usr/share/caddy/index.html \
  -v ./Caddyfile:/etc/caddy/Caddyfile \
  -v ./exports:/certs \
  --name keyser-tutorial \
  caddy
```

At this point, run curl without any argument shall raise an error because the certificate wasn't signed by a public authority like Let's Encrypt.

```bash
curl https://localhost:8443
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

However, with a valid certificate loaded, the `curl` command succeeds.

```bash
curl \
  --cacert ./exports/com.domain.app.www.cert.pem \
  --resolve 'www.app.domain.com:8443:127.0.0.1' \
  https://www.app.domain.com:8443
```

To enabling web browsing, the certificate must be uploaded to its registry. On MacOS, the certificate must be loaded to the "Keychain Access" application and, then, marked as trusted. Firefox, Safari and Chrome won't complain about the certificate origin.

## Tutorial for wildcard certificate

Keyser supports wildcard domain certificates, meaning you can generate a single certificate for all subdomains of your domain. You can follow these steps.

Considering you already have a valid CA, generate a first certificate for your root domain:

```bash
keyser cert -i \
  -e no-reply@localhost \
  domain.com
```

Then generate the wildcard certificate for all your domain's subdomains:

```bash
keyser cert \
  -d '*.domain.com" \
  '*.domain.com'
```

Export your certificate to your location:

```bash
keyser cert_export -c \
  '*.domain.com' ~/path/to/your/certs
```

Finally, display your certificate to make sure it has correctly been generated:

```bash
keyser cert_view \
  '*.domain.com'
```

When using wildcards, make sure you pass your parameter as a string.

This will work:

```bash
keyser cert \
  -d '*.domain.com' \
  '*.domain.com'
  # Will work ✅
```

While this won't:

```bash
keyser cert \
  -d *.domain.com \
  *.domain.com
  # Will not work ❌
```

## Tests

The test suite is launched with `./test/all.sh`. Run `./test/<name>.sh` to execute a single test.
