# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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