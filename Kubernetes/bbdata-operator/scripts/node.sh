#!/usr/bin/env bash


# Get the template path for Node.js
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/node"

# Deploy the WebApp server and wait for it to be ready
kubectl apply -f "$FILEPATH/deployment.yml"
NAME=$(kubectl get pods -l app=nodejs -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME