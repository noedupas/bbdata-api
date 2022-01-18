#!/bin/bash

# Prerequisites:    - jq:       sudo apt install jq
#                   - k3d:      curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

if ! command -v jq &> /dev/null
then
    echo "jq could not be found !"
    read -r -p "Would you like to install it ? [Y/n]" response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        sudo apt install jq
    else
        exit
    fi
fi

if ! command -v k3d &> /dev/null
then
    echo "k3d could not be found !"
    read -r -p "Would you like to install it ? [Y/n]" response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
        curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
    else
        exit
    fi
fi

k3d cluster create myCluster -p "8080-8088:30080-30088@agent:0" -a 3

echo "===================       STARTING CASSANDRA       ==================="
./cassandra/init.sh
echo "=================== CASSANDRA DONE, STARTING KAFKA ==================="
./kafka/init.sh
echo "===================   KAFKA DONE, STARTING MYSQL   ==================="
./mysql/init.sh
echo "===================   MYSQL DONE, STARTING SPRING   ==================="
./spring/init.sh
echo "================     SPRING DONE, STARTING WEBAPP      ==============="
./node/init.sh
echo "===================      WEBAPP DONE, ALL DONE      =================="