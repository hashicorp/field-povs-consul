#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#build 8
#meta
dc_name="dc-1"
node_count=3
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join=[\"10.0.7.196:8301\",\"10.0.7.105:8301\",\"10.0.7.106:8301\"] #["provider=aws tag_key=consulserver tag_value=yes"]
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o=" #"$(consul keygen)" 
isPrimaryDC=true

retry_join=${retry_join}
dc_name=${dc_name} 
node_count=${node_count}
retry_join=${retry_join}
encryptkey=${encryptkey}


mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

cd /opt/consul/tls/


# #consul
sudo tee /etc/consul.d/consul.hcl > /dev/null << EOF
datacenter = "$dc_name"
client_addr = "0.0.0.0"
bind_addr = "$local_ipv4"
data_dir = "/opt/consul"
encrypt = "$encryptkey"
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
cert_file = "/opt/consul/tls/$dc_name-server-consul-0.pem"
key_file = "/opt/consul/tls/$dc_name-server-consul-0-key.pem"
license_path = "/opt/consul/license.hclic"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
server = true
bootstrap_expect = $node_count
retry_join = $retry_join
ui = true
enable_central_service_config = true
auto_encrypt {
  allow_tls = true
}
connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}
ports {
 grpc = 8502
 https = 8501
}
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  down_policy = "extend-cache"
}
EOF

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

sudo systemctl enable consul.service
sudo systemctl restart consul.service