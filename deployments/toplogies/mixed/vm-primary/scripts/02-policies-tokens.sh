#!/bin/bash

#VARS
BOOTSTRAP_TOKEN=$1

#api
echo "Using Consul API: ${CONSUL_HTTP_ADDR}"

#tokens & policies
echo "Using bootstrap token: ${BOOTSTRAP_TOKEN}"
export CONSUL_HTTP_TOKEN=${BOOTSTRAP_TOKEN}

#agent
echo "Creating agent policy"
consul acl policy create -name "agent" -description "agent" -rules @../policies/agent.hcl
echo "Created agent token: $(consul acl token create -policy-name agent -format=json | jq -r .SecretID)"

#replication
echo "Creating replication policy"
consul acl policy create -name "replication" -description "replication" -rules @../policies/replication.hcl
echo "Created replication token: $(consul acl token create -policy-name replication -format=json | jq -r .SecretID)"

#mesh gateway
echo "Creating mesh gateway policy"
consul acl policy create -name "mesh-gateway" -description "mesh gateway" -rules @../policies/mesh-gateway.hcl
echo "Created mesh gateway token: $(consul acl token create -policy-name mesh-gateway -format=json | jq -r .SecretID)"

exit 0
