#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#build 8
#meta

consul_master_token="298f7914-e29c-87f1-f0c4-332d28564452"


nodetoken=$(consul acl token create \
  -token=$consul_master_token \
  -description "node token" \
  -policy-name node-policy \
  -format=json | jq -r ".SecretID") 

consul acl set-agent-token \
  -token=$consul_master_token \
  agent $nodetoken