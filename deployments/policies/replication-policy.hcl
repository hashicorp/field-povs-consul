acl = "write"
  operator = "write"
  agent_prefix "" {
    policy = "read"
  }
  node_prefix "" {
    policy = "write"
  }
  namespace_prefix "" {
    service_prefix "" {
      policy = "read"
      intentions = "read"
    }
  }