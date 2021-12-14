#!/bin/bash

# Prerequisites:    - jq:       sudo apt install jq
#                   - k3d:      curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

k3d cluster create myCluster -a 3

echo "===================       STARTING CASSANDRA       ==================="
./cassandra/init.sh
echo "=================== CASSANDRA DONE, STARTING KAFKA ==================="
./kafka/init.sh