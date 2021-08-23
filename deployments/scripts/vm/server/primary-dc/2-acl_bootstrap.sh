#!/bin/bash
#build 8
#meta
#run this script only when all servers have been bootstrapped
#sleep is necessary to make sure the servers have time to boostrap
node_policyFile="/opt/consul/policies/node-policy.hcl"

sleep 10

consul_master_token=$(consul acl bootstrap -format=json | jq -r ".SecretID") #${consul_master_token}

consul acl policy create \
  -token=${consul_master_token} \
  -name node-policy \
  -rules @$node_policyFile

#repeat the bellow 2 on each node
nodetoken=$(consul acl token create \
  -token=${consul_master_token} \
  -description "node token" \
  -policy-name node-policy \
  -format=json | jq -r ".SecretID") 

consul acl set-agent-token \
  -token=${consul_master_token} \
  agent $nodetoken
echo $consul_master_token
