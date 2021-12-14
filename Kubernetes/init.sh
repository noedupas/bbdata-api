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

k3d cluster create myCluster -p "8080:30080@agent:0" -a 3

echo "===================       STARTING CASSANDRA       ==================="
./cassandra/init.sh
echo "=================== CASSANDRA DONE, STARTING KAFKA ==================="
./kafka/init.sh
echo "===================   KAFKA DONE, STARTING MYSQL   ==================="
kubectl apply -f mysql-deployment.yml
NAME=$(kubectl get pods -l app=mysql -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME
echo "===================   MYSQL DONE, STARTING SPRING   ==================="
kubectl apply -f spring-deployment.yml
NAME=$(kubectl get pods -l app=spring -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME
kubectl apply -f spring-service.yml
echo "===================      SPRING DONE, ALL DONE      ==================="