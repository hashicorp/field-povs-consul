#!/bin/bash
#build 8
#meta
dc_name="dc-2"
primary_dc="dc-1"
node_count=3
local_ipv4="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
retry_join=[\"10.0.7.246:8301\",\"10.0.7.14:8301\",\"10.0.7.59:8301\"] #["provider=aws tag_key=consulserver tag_value=yes"]
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o=" #"$(consul keygen)" 
gwIP="15.236.207.173"
replicationToken="7f380737-b86f-6d11-d54a-3bf77f58eb7f"
consul_hclfile="../../../../config-files/secondary-dc-server.hcl"

#the bellow is necessary for later integration with TF. Will make it nicer later
primary_dc=${primary_dc}
dc_name=${dc_name} 
node_count=${node_count}
gwIP=${gwIP}
replicationToken=${replicationToken}
consul_hclfile=${consul_hclfile}
mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

cd /opt/consul/tls/

sudo sed "s/\$dc_name/$dc_name/g;\
  s/\$gwIP/$gwIP/g;\
  s/\$primary_dc/$primary_dc/g;\
  s/\$retry_join/$retry_join/g;\
  s/\$encryptkey/$encryptkey/g;\
  s/\$node_count/$node_count/g;\
  s/\$replicationToken/$replicationToken/g "\
  $consul_hclfile \
  > /etc/consul.d/consul.hcl

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

sudo systemctl enable consul.service
sudo systemctl restart consul.service