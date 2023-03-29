# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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