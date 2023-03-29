#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#build 8
#meta
dc_name="dc-2"
agent_token="16d1f7d8-6db7-15ab-b236-01ed52ca749b"
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join=[\"10.0.7.246:8301\",\"10.0.7.14:8301\",\"10.0.7.59:8301\"] #["provider=aws tag_key=consulserver tag_value=yes"]
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o=" #"$(consul keygen)" 

dc_name=${dc_name} 
agent_token=${agent_token}
mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

# #consul
sudo tee /etc/consul.d/consul.hcl > /dev/null << EOF
datacenter = "$dc_name"
client_addr = "0.0.0.0"
bind_addr = "$local_ipv4"
data_dir = "/opt/consul"
encrypt = "$encryptkey"
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
retry_join = $retry_join
log_level = "DEBUG"
auto_encrypt {
 tls = true
}
connect {
  enabled = true
}
ports {
 grpc = 8502
}
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  down_policy = "extend-cache"
  tokens {
    agent = "$agent_token"
  }
}
EOF

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

sudo systemctl enable consul.service
sudo systemctl restart consul.service