#!/bin/bash

caCert="certs_test/consul-agent-ca.pem"
caKey="certs_test/consul-agent-ca-key.pem"
dcName="dc-3"
primaryDC="dc-1"
primaryGW='["13.36.37.27:443"]'
licensFile="/Files/license/license.hclic"
nameSpace="meshtest"
replicationToken="11a82f8a-e173-3b60-a728-2be08f1a1614"
gossipEncryptionKey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o="
fileName="helm-dc3.yaml"


if [ "$nameSpace" != "default" ]
then
    kubectl create namespace $nameSpace
fi

kubectl create secret generic consul-federation \
    --from-file=caCert=$caCert \
    --from-file=caKey=$caKey \
    --from-literal=replicationToken=$replicationToken \
    --from-literal=gossipEncryptionKey=$gossipEncryptionKey \
    -n $nameSpace

kubectl create secret generic consul-ent-license \
    --from-file=key=$licensFile -n $nameSpace

#wriring to file to make debugging of the helm easier later. 
sed "s/"\$\{primaryDC\}"/${primaryDC}/g;s/"\$\{primaryGW\}"/$primaryGW/g;s/"\$\{dcName\}"/${dcName}/g" \
    ../helm/server-secondary.yaml   \
    > $fileName

helm install -n $nameSpace consul hashicorp/consul  --wait --debug -f $fileName


