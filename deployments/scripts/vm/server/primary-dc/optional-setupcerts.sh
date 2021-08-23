#!/bin/bash
#meta

#to be run on one server and then copy over to the others.
dc_name=${dc_name} 

cd /opt/consul/tls

sudo consul tls ca create
sudo consul tls cert create -server -dc $dc_name -node "*"
sudo consul tls cert create -client -dc $dc_name