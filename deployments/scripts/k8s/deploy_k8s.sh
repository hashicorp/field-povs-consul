#!/bin/bash
#
#https://www.consul.io/docs/k8s/installation/install

usage="$(basename "$0") [-h] [-p isPrimary] [-c caCert] [-k caKey] [-k dcName] [-d1 primaryDC] /
[-g primaryGW] [-l licensFile] [-n nameSpace] [-r replicationToken] [-e gossipEncryptionKey] [-f helmFile]

where:
    -h  show this help text
    -p  Is this a primary DC (default true)
    -c  ca Certificagte location
    -k  ca KEY file locagtion
    -d  DC Name
    -d1 Name of the primary DC. In case this is a secondary DC
    -g IP address(es) of the primary meshgateway. Example: '[\"13.36.37.27:443\"]'
    -l Location of the license file
    -s K8s namespace to install consul in (default:default)
    -n node count (Default 3)
    -r replication token from the primary dc. In case of a secondary DC 
    -e gossipEncryptionKey
    -f helmFile
"
while getopts :h:p:c:k:d:d1:g:l:s:n:r:e:f: flag
do
  case "$flag" in
    p) isPrimaryDC=$OPTARG;;
    c) caCert=$OPTARG;;
    k) caKey=$OPTARG;;
    d) dcName=$OPTARG;;
    d1) primaryDC=$OPTARG;;
    g) primaryGW=$OPTARG;;
    l) licensFile=$OPTARG;;
    s) nameSpace=$OPTARG;;
    n) node_count=$OPTARG;;
    r) replicationToken=$OPTARG;;
    e) gossipEncryptionKey=$OPTARG;;
    f) helmFile=$OPTARG;;
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
nameSpace=${nameSpace:-"default"}

# if [ ! "$caCert" ] || [ ! "$caKey" ] || [ ! "$dcName" ] || [ ! "$primaryDC" ] || [ ! "$primaryGW" ] || [ ! "$licensFile" ] || [ ! "$replicationToken" ] || [ ! "$gossipEncryptionKey" ] || [ ! "$helmFile" ]; then
#   echo "Arguments -d -i -r -e -f must be provided"
#   echo "$usage" >&2; exit 1
# fi

#create the namespace if another namespace then default is used

if [ "$nameSpace" != "default" ]
then
    kubectl create namespace $nameSpace
fi

#apply the enterprise license file.  This must happen before installing consul
#https://www.consul.io/docs/k8s/installation/deployment-configurations/consul-enterprise
kubectl create secret generic consul-ent-license \
    --from-file=key=$licensFile -n $nameSpace


#https://www.consul.io/docs/k8s/installation/multi-cluster/kubernetes
if $isPrimaryDC
then
    kubectl create secret generic consul-federation -n $nameSpace  \
    --from-literal=gossipEncryptionKey=$gossipEncryptionKey \

     sed "s/"\$\{primaryDC\}"/${primaryDC}/g;s/"\$\{primaryGW\}"/$primaryGW/g;s/"\$\{dcName\}"/${dcName}/;s/"\$\{node_count\}"/${node_count}/g" \
    $helmFile \
    > helmdeploy.yaml
else
    kubectl create secret generic consul-federation \
    --from-file=caCert=$caCert \
    --from-file=caKey=$caKey \
    --from-literal=replicationToken=$replicationToken \
    --from-literal=gossipEncryptionKey=$gossipEncryptionKey \
    -n $nameSpace

    sed "s/"\$\{primaryDC\}"/${primaryDC}/g;s/"\$\{primaryGW\}"/$primaryGW/g;s/"\$\{dcName\}"/${dcName}/;s/"\$\{node_count\}"/${node_count}/g" \
    $helmFile   \
    > helmdeploy.yaml 
fi

#https://www.consul.io/docs/k8s/installation/install
helm install -n $nameSpace consul hashicorp/consul  --wait --debug -f "helmdeploy.yaml"


# isPrimaryDC=true
# caCert="certs_test/consul-agent-ca.pem"
# caKey="certs_test/consul-agent-ca-key.pem"
# dcName="dc-3"
# primaryDC="dc-1"
# primaryGW='["13.36.37.27:443"]'
# licensFile="/Files/license/license.hclic"
# nameSpace="meshtest"
# replicationToken="11a82f8a-e173-3b60-a728-2be08f1a1614"
# gossipEncryptionKey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o="
# helmFile="helm-dc3.yaml"