operator = "write"
acl = "write"
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
  intentions = "read"
}
namespace_prefix "" {
  acl = "write"
  service_prefix "" {
    policy = "read"
    intentions = "read"
  }
}
