#!/bin/bash -xe

#Clear old certs
rm -f certs/*

#Setup
echo "Generating Consul deployment artifacts..."

#Creating bootstrap token - https://www.consul.io/docs/security/acl/acl-system#builtin-tokens
BOOTSTRAP_TOKEN=$(/usr/bin/uuidgen)
echo "Created local bootstrap token: ${BOOTSTRAP_TOKEN}"

#Gossip Key - https://learn.hashicorp.com/tutorials/consul/gossip-encryption-secure
GOSSIP_KEY=$(consul keygen)
echo "Created gossip key: ${GOSSIP_KEY}"

#Create a CA - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "Creating CA for TLS..."
openssl genrsa -out certs/consul-agent-ca.key 2048
openssl req -sha256 -new -x509 -nodes -key certs/consul-agent-ca.key -days 3650 -out certs/consul-agent-ca.pem -subj '/CN=HashiCorp CA' -extensions 'v3_ca' -config <(
cat <<-EOF
[ req ]
distinguished_name  = dn
x509_extensions     = v3_ca
[ dn ]
CN = HashiCorp CA
[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
EOF
)

#Primary Cluster TLS - DC1 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "Creating TLS certs for the primary dc1 cluster..."
openssl req -sha256 -new -newkey rsa:2048 -nodes -keyout certs/server0.dc1.consul.key -out certs/server0.dc1.consul.csr -subj '/CN=consul-server-0.dc1.consul' -config <(
cat <<-EOF
[req]
req_extensions = req_ext
distinguished_name = dn
[ dn ]
CN = consul-server-0.dc1.consul
[ req_ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
basicConstraints = critical, CA:false
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = consul-server-0.server.dc1.consul
DNS.2 = server.dc1.consul
DNS.3 = localhost
IP.1  = 127.0.0.1
EOF
)
openssl x509 -req -sha256 -in certs/server0.dc1.consul.csr -CA certs/consul-agent-ca.pem -CAkey certs/consul-agent-ca.key -CAcreateserial -out certs/server0.dc1.consul.crt -extensions 'x509_ext' -extfile <(
cat <<-EOF
[req]
req_extensions = x509_ext
distinguished_name = dn
[ dn ]
CN = consul-server-0.dc1.consul
[ x509_ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
basicConstraints = critical, CA:false
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = consul-server-0.server.dc1.consul
DNS.2 = server.dc1.consul
DNS.3 = localhost
IP.1  = 127.0.0.1
EOF
)

#Primary Cluster TLS - DC2 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "Creating TLS certs for the secondary dc2 cluster..."
openssl req -sha256 -new -newkey rsa:2048 -nodes -keyout certs/server0.dc2.consul.key -out certs/server0.dc2.consul.csr -subj '/CN=consul-server-0.dc2.consul' -config <(
cat <<-EOF
[req]
req_extensions = req_ext
distinguished_name = dn
[ dn ]
CN = consul-server-0.dc2.consul
[ req_ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
basicConstraints = critical, CA:false
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = consul-server-0.server.dc2.consul
DNS.2 = server.dc2.consul
DNS.3 = localhost
IP.1  = 127.0.0.1
EOF
)
openssl x509 -req -sha256 -in certs/server0.dc2.consul.csr -CA certs/consul-agent-ca.pem -CAkey certs/consul-agent-ca.key -CAserial certs/consul-agent-ca.srl -out certs/server0.dc2.consul.crt -extensions 'x509_ext' -extfile <(
cat <<-EOF
[req]
req_extensions = x509_ext
distinguished_name = dn
[ dn ]
CN = consul-server-0.dc2.consul
[ x509_ext ]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
basicConstraints = critical, CA:false
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = consul-server-0.server.dc2.consul
DNS.2 = server.dc2.consul
DNS.3 = localhost
IP.1  = 127.0.0.1
EOF
)

#Primary Cluster TLD - DC3 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "TLS will be managed by the Consul helm chart. Skipping ..."

exit 0
