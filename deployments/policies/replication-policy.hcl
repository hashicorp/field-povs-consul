# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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