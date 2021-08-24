#!/bin/bash
#build 8
#meta
usage="$(basename "$0") [-h] [-d CONSUL DC] [-n NODE_COUND] \
[-i  PRIVATE_IP] [-r RETRY_JOIN] [-e GOSSIP_ENCRYPTION] [-p PRIMARY_DC(true)] [-f HCL TEMPLATE FILE]

where:
    -h  show this help text
    -n  node-count. Default:3
    -i  local ipv4 address.
    -r  list of IP addresses and port for the consul servers to which to join this agent. ex.: [\"10.0.7.196:8301\",\"10.0.7.105:8301\",\"10.0.7.106:8301\"] 
    -e  gossip encryption key to use
    -p  is this consul DC a primary consul DC (default: true)
    -f  location of the consul hcl template file to be used.   
"
while getopts :hd:n:i:r:e:p:f: flag
do
  case "$flag" in
    d) dc_name=$OPTARG;;
    n) node_count=$OPTARG;;
    i) local_ipv4=$OPTARG;;
    r) retry_join=$OPTARG;;
    e) encryptkey=$OPTARG;;
    p) isPrimaryDC=$OPTARG;;
    f) consul_hclfile=$OPTARG;;
    h) echo "$usage"
       exit
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
node_count=${node_count:-3}
isPrimaryDC=${isPrimaryDC:-true}

if [ ! "$dc_name" ] || [ ! "$local_ipv4" ] || [ ! "$retry_join" ] || [ ! "$encryptkey" ] || [ ! "$consul_hclfile" ]; then
  echo "Arguments -d -i -r -e -f must be provided"
  echo "$usage" >&2; exit 1
fi


# node_count=3
# local_ipv4="10.1.1.1"
# retry_join=[\"10.0.7.196:8301\",\"10.0.7.105:8301\",\"10.0.7.106:8301\"] 
# encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o="
# isPrimaryDC=true
# consul_hclfile="../../../../config-files/primary-dc-server.hcl"

retry_join=${retry_join}
dc_name=${dc_name} 
node_count=${node_count}
retry_join=${retry_join}
encryptkey=${encryptkey}


mkdir -p /opt/consul/tls/
mkdir -p /opt/policies

cd /opt/consul/tls/

echo "Creating consul HCL file"
sudo sed "s/\$dc_name/$dc_name/g;\
  s/\$local_ipv4/$local_ipv4/g;\
  s/\$encryptkey/$encryptkey/g;\
  s/\$node_count/$node_count/g;\
  s/\$retry_join/$retry_join/g "\
  $consul_hclfile \
  > /etc/consul.d/consul.hcl

sudo chown -R consul:consul /opt/consul/
sudo chown -R consul:consul /etc/consul.d/

echo "Enabling Consul"
sudo systemctl enable consul.service
echo "Starting Consul"
sudo systemctl restart consul.service