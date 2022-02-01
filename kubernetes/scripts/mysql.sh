#!/usr/bin/env bash


# Get the template path for mysql
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/mysql"

# Deploy MySQL and wait for it to be ready
cp "$FILEPATH/deployment.yml" "$FILEPATH/deployment_deploy.yml"
sed -i "s/NAMESPACE/$namespace/" "$FILEPATH/deployment_deploy.yml"

kubectl -n $namespace apply -f "$FILEPATH/deployment_deploy.yml"
NAME=$(kubectl -n $namespace get pods -l app=mysql -o "jsonpath={.items[0].metadata.name}")
kubectl -n $namespace wait --for=condition=ready pod $NAME