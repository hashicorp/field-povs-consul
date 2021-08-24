#!/bin/bash

kubectl create secret generic consul-federation \
    --from-literal=caCert="$(cat certs/consul-agent-ca.pem)" \
    --from-literal=caKey="$(cat certs/consul-agent-ca.key)" \
    --from-literal=replicationToken="<your acl replication token>" \
    --from-literal=gossipEncryptionKey="<your gossip encryption key>"

exit 0
