#agent
datacenter = "dc2"
primary_datacenter = "dc1"
advertise_addr = "${lan_ipv4}"
client_addr = "0.0.0.0"
data_dir = "/opt/consul/data"
log_level = "INFO"
retry_join = ["${server1}"]

#ports - https://www.consul.io/docs/agent/options#ports
ports = {
  grpc = 8502
}

#gossip - https://learn.hashicorp.com/tutorials/consul/gossip-encryption-secure
encrypt = "${gossip_key}"

#connect
connect = {
  enabled = true
}

#tls - https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure#client-certificate-distribution
ca_file = "/opt/consul/tls/ca-cert.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  tls = true
}

#acl - node policy - https://learn.hashicorp.com/tutorials/consul/access-control-setup-production
acl = {
  enabled        = true
  default_policy = "deny"
  down_policy   = "extend-cache"
  enable_token_persistence = true
  enable_token_replication = true
  tokens {
    agent  = "${node_token}"
  }
}
