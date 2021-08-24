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