dc_name="dc-2"
mgw_token="1c2e8315-e082-06a6-8261-2cfbb47acd85"

mgw_token=${mgw_token}
local_ipv="$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
public_ip="35.180.192.39"


# sudo tee /etc/consul.d/envoy.env > /dev/null << EOF
# export CONSUL_CACERT=/opt/consul/tls/consul-agent-ca.pem
# export CONSUL_CLIENT_CERT=/opt/consul/tls/dc-1-client-consul-0.pem
# export CONSUL_CLIENT_KEY=/opt/consul/tls/dc-1-client-consul-0-key.pem
# export CONSUL_HTTP_SSL=true
# export CONSUL_HTTP_ADDR=localhost:8501
# EOF
# EnvironmentFile=/etc/consul.d/envoy.env

sudo tee /etc/systemd/system/envoy.service > /dev/null << EOF
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -expose-servers -gateway=mesh -register -service "mesh-gateway" -address "$local_ipv:443" -wan-address "$public_ip:443" -token $mgw_token -tls-server-name "server.$dc_name.consul" -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl enable envoy.service
sudo systemctl restart envoy.service