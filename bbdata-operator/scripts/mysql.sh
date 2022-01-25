#!/usr/bin/env bash


# Get the template path for mysql
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/mysql"

# Deploy MySQL and wait for it to be ready
kubectl -n bbdata apply -f "$FILEPATH/deployment.yml"
NAME=$(kubectl -n bbdata get pods -l app=mysql -o "jsonpath={.items[0].metadata.name}")
kubectl -n bbdata wait --for=condition=ready pod $NAME