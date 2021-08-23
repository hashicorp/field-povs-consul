#!/bin/bash
#build 8
#meta
dc_name="dc-2"
primary_dc="dc-1"
node_count=3
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join=[\"10.0.7.246:8301\",\"10.0.7.14:8301\",\"10.0.7.59:8301\"] #["provider=aws tag_key=consulserver tag_value=yes"]
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o=" #"$(consul keygen)" 
gwIP="15.236.207.173"
replicationToken="7f380737-b86f-6d11-d54a-3bf77f58eb7f"

#the bellow is necessary for later integration with TF. Will make it nicer later
primary_dc=${primary_dc}
dc_name=${dc_name} 
node_count=${node_count}
gwIP=${gwIP}
replicationToken=${replicationToken}

mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

cd /opt/consul/tls/


# #consul
sudo tee /etc/consul.d/consul.hcl > /dev/null << EOF
datacenter = "$dc_name"
primary_gateways = ["$gwIP:443"]
primary_datacenter = "$primary_dc"
client_addr = "0.0.0.0"
data_dir = "/opt/consul"
license_path = "/opt/consul/license.hclic"
encrypt = "$encryptkey"
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
cert_file = "/opt/consul/tls/$dc_name-server-consul-0.pem"
key_file = "/opt/consul/tls/$dc_name-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
server = true
bootstrap_expect = 1
ui = true
enable_central_service_config = true
auto_encrypt {
  allow_tls = true
}
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    agent = "$replicationToken"
    replication = "$replicationToken"
  }

}
ports {
 grpc = 8502,
 https = 8501
}
connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}
EOF

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

sudo systemctl enable consul.service
sudo systemctl restart consul.service