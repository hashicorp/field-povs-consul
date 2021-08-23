#!/bin/bash
#build 8
#meta
dc_name="dc-1"
node_count=3
local_ipv4="10.1.1.1"
retry_join=[\"10.0.7.196:8301\",\"10.0.7.105:8301\",\"10.0.7.106:8301\"] 
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o="
isPrimaryDC=true
consul_hclfile="../../../../config-files/primary-dc-server.hcl"

retry_join=${retry_join}
dc_name=${dc_name} 
node_count=${node_count}
retry_join=${retry_join}
encryptkey=${encryptkey}


mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

cd /opt/consul/tls/

sudo sed "s/\$dc_name/$dc_name/g;\
  s/\$local_ipv4/$local_ipv4/g;\
  s/\$encryptkey/$encryptkey/g;\
  s/\$node_count/$node_count/g;\
  s/\$retry_join/$retry_join/g "\
  $consul_hclfile \
  > /etc/consul.d/consul.hcl

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

sudo systemctl enable consul.service
sudo systemctl restart consul.service