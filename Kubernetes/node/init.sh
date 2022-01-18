#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

kubectl apply -f "$SCRIPTPATH/deployment.yml"
NAME=$(kubectl get pods -l app=nodejs -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME
echo "============================"
kubectl apply -f "$SCRIPTPATH/service.yml"