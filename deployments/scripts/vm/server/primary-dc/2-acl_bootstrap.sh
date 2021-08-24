#!/bin/bash
#build 8
#meta
#run this script only when all servers have been bootstrapped
#sleep is necessary to make sure the servers have time to boostrap

#location of the node policy file. This should be coppied by the deployment script to the right location
usage="$(basename "$0") [-h] [-n Node Policy]

where:
    -h  show this help text
    -n  location of the node policy file to be used
"
while getopts :hd:n:i:r:e:p:f: flag
do
  case "$flag" in
    d) node_policyFile=$OPTARG;;
    h) echo "$usage"
       exit
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done

if [ ! "$node_policyFile" ] ; then
  echo "Arguments -n must be provided"
  echo "$usage" >&2; exit 1
fi





sleep 10

consul_master_token=$(consul acl bootstrap -format=json | jq -r ".SecretID") #${consul_master_token}

consul acl policy create \
  -token=${consul_master_token} \
  -name node-policy \
  -rules @$node_policyFile

#repeat the bellow 2 on each node
nodetoken=$(consul acl token create \
  -token=${consul_master_token} \
  -description "node token" \
  -policy-name node-policy \
  -format=json | jq -r ".SecretID") 

consul acl set-agent-token \
  -token=${consul_master_token} \
  agent $nodetoken
echo $consul_master_token
