**Disclaimer: This setup is for POC purposes and not fit for production**

Prerequisites on the machine for running the scripts:
- Install packer
- Install consul client
- Install kubectl
- Install helm

## STEP BY STEP GUIDE on Installing Consul on VM´s with full zero trust and TLS. 

This guide describes the following:
- How top install 2 DC´s connected with wan federation.
- TLS is enabled everywhere
- Default Deny
- Auto Encrypt

The scipts have number indicating the order in which to run them

### Setup of DC1 on VM´s

Prerequisites: Have 3(Default) VM´s on the same network

1. Open 1-consul_setup.sh
Make sure to define followin variables according to your environment. The bellow is an example:

dc_name="dc-1"
node_count=3
local_ipv4="10.0.7.145"
retry_join=[\"10.0.7.169:8301\",\"10.0.7.190:8301\",\"10.0.7.52:8301\"] #["provider=aws tag_key=consulserver tag_value=yes"]
encryptkey="KxHMa9auQmZrFrv0me5kQxhHb23BEKKtkSJDEOWhW4o=" # run `consul keygen` to get a key

Run the script on all servers for the primary DC
2. Run the script `2-acl_bootstrap.sh`
This script will output the consul master token used. You will need this one in the following script
3. In the folder <on-all-servers> you need to run the following script:
´1-set_agent_token.sh´
Make sure to specify the consul_master_token variable with the value from the script in step 2
This will create a node token for each of the servers and set the agent token to be this token
4. We will not start configuring the meshgateway ona client server. 

Run the all scripts in the client folders, making sure you specify the variables in the beginning of each script:
- `1-mgw-setup-acl.sh`: 
    - consul_master_token: the token created in step 2
    - consul_server_addr: the address of one of the consul servers
    - isPrimaryDC: set to true in the first dc. Thill make sure a replication token is created. 
This script will output 3 tokens:
    - Replication token: only in the case it is a primary DC)
    - mesh-gateway token: to be used when setting up envoy
    - node token: to be used when configuring the node to join consul DC
-  `2-consul_setup.sh`:
    - dc_name: must be the same as the one used in step 1
    - agent_token: the output from the previous script (node-token)
    - local_ipv4: private ip address
    - retry_join: a list of servers belonging to the DC. ex: retry_join=[\"10.0.7.96:8301\",\"10.0.7.58:8301\",\"10.0.7.212:8301\"] 
    - encryptkey: gossip encription key used in step 1
-  `3-mgw_envoy_setup.sh`:
    - dc_name: same as step 1
    - mgw_token: output from the first script on this server
    - local_ipv: local ip address
    - public_ip: public IP to be used by the meshgateway

<Wahoo the first DC is not setup>
Also here make sure to use the master token created in step 2 and set the consul_master_token variable accordingly.

### Setup of DC2 on VM´s
Ruh the scripts in the folder: Modules/files/scripts/vm/server/secondary-dc
Run eht e
- 1-consul_setup.sh
Make sure the following variables are set. Example:
    - dc_name: the name for this DC
    - primary_dc: the name for the primary dC
    - node_count=3 (Default)
    - local_ipv4=local IP address
    - retry_join: the list of consul DC servers. Ex: [\"10.0.7.246:8301\",\"10.0.7.14:8301\",\"10.0.7.59:8301\"]
    - encryptkey: The gossip encryption key used 
    - gwIP: the public IP of the meshgateway for the primary DC
    - replicationToken: the token created in step 4 of the first DC
In the client folder run the following (repeat=)
-  `2-consul_setup.sh`:
    - dc_name: dc name for the second dc
    - agent_token: you can use the same node token as for the MGW for the primary dc or create a new one
    - local_ipv4: private ip address
    - retry_join: a list of servers belonging to the DC. ex: [\"10.0.7.246:8301\",\"10.0.7.14:8301\",\"10.0.7.59:8301\"]
    - encryptkey: gossip encription key used in step 1
-  `3-mgw_envoy_setup.sh`:
    - dc_name: name of the second DC
    - mgw_token: you can use the same token as the one created for DC1
    - local_ipv: local ip address
    - public_ip: public IP to be used by the meshgateway

### Setup of DC3 on k8s
First make sure you have the caCert and caKey you used in the first step and that the script has access to that path. The same goes for the license file
In the k8s/secondary run the following script:









