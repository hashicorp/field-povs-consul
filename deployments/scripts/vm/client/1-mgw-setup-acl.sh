#!/bin/bash
#build 8
#meta

consul_master_token="298f7914-e29c-87f1-f0c4-332d28564452"
consul_server_addr="10.0.7.106:8500"
isPrimaryDC=true

replicationPolicy="/opt/consul/policies/replication-policy.hcl"
mgwPolicy="/opt/consul/policies/mgw.hcl"
proxyDefaultPolicy="/opt/policies/default-policy.hcl"


isPrimaryDC=${isPrimaryDC}
consul_master_token=${consul_master_token}
consul_server_addr=${consul_server_addr}

consul acl policy create \
  -name mgw-policy \
  -rules @$mgwPolicy \
  -token=$consul_master_token \
  -http-addr=$consul_server_addr 

#token to be used when bootstrapping envoy for meshgateway
mgwToken=$(consul acl token create \
  -description "mgw token" \
  -policy-name mgw-policy \
  -token=$consul_master_token \
  -http-addr=$consul_server_addr \
  -format=json | jq -r ".SecretID")


consul config write \
  -token=$consul_master_token \
  -http-addr=$consul_server_addr \
  $proxyDefaultPolicy

if  $isPrimaryDC
then
  consul acl policy create \
    -token=$consul_master_token \
    -name replication-policy \
    -rules @$replicationPolicy\
    -token=$consul_master_token \
    -http-addr=$consul_server_addr 

  replicationToken=$(consul acl token create \
    -token=$consul_master_token \
    -description "replication token" \
    -policy-name replication-policy \
    -format=json \
    -token=$consul_master_token \
    -http-addr=$consul_server_addr | jq -r ".SecretID")
fi

nodetoken=$(consul acl token create \
  -token=$consul_master_token \
  -description "node token" \
  -policy-name node-policy \
  -http-addr=$consul_server_addr  \
  -format=json | jq -r ".SecretID") 

echo "Replication, for use in secondary dc,Token is: $replicationToken"
echo "mesh-gateway service token is: $mgwToken"
echo "node token is: $nodetoken"