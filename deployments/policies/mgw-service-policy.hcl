# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

agent_prefix "" {
  policy = "read"
}
service_prefix "mesh-gateway" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}