#!/bin/bash -xe

#Clear old certs
rm -f *.pem
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
consul tls ca create

#Primary Cluster TLS - DC1 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "Creating TLS certs for the primary dc1 cluster..."
consul tls cert create -server -dc=dc1 -node=consul-server-0

#Primary Cluster TLS - DC2 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "Creating TLS certs for the secondary dc2 cluster..."
consul tls cert create -server -dc=dc2 -node=consul-server-0

#Primary Cluster TLD - DC3 - https://learn.hashicorp.com/tutorials/consul/tls-encryption-openssl-secure
echo "TLS will be managed by the Consul helm chart. Skipping ..."

#move the certs
cp *.pem certs/
rm -f *.pem

exit 0
