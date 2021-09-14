#agent - https://learn.hashicorp.com/tutorials/consul/get-started-agent
datacenter = "dc2"
primary_datacenter = "dc1"
data_dir = "/opt/consul/data"
client_addr = "0.0.0.0"
advertise_addr = "${lan_ipv4}"
log_level = "DEBUG"

#server agent - https://www.consul.io/docs/install/bootstrapping
bootstrap_expect = 1
server = true
ui = true
node_name = "consul-server-0"

#server license - https://www.consul.io/docs/enterprise/license/overview
license_path = "/etc/consul.d/consul.hclic"

#ports - https://www.consul.io/docs/agent/options#ports
ports {
 http = 8500
 https = 8501
}

#gossip - https://learn.hashicorp.com/tutorials/consul/gossip-encryption-secure
encrypt = "${gossip_key}"

#connect - https://www.consul.io/docs/connect/gateways/mesh-gateway/wan-federation-via-mesh-gateways
connect = {
  enable_mesh_gateway_wan_federation = true
  enabled = true
}

#mesh gateway federation - https://www.consul.io/docs/connect/gateways/mesh-gateway/wan-federation-via-mesh-gateways
primary_gateways = ["${dc1_mgw}"]


#acl - https://learn.hashicorp.com/tutorials/consul/access-control-setup-production
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  enable_token_replication = true
  tokens {
    agent  = "${replication_token}"
    replication = "${replication_token}"
  }
}

#tls - https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure#client-certificate-distribution
ca_file = "/opt/consul/tls/ca-cert.pem"
cert_file = "/opt/consul/tls/server-cert.pem"
key_file = "/opt/consul/tls/server-key.pem"
verify_incoming_rpc = true
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  allow_tls = true
}
