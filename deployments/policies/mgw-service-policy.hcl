# Copyright IBM Corp. 2021, 2023
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