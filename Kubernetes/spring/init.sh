#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

CASS_USER=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.username' | base64 --decode)
CASS_PASS=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.password' | base64 --decode)

cp "$SCRIPTPATH/deployment_orig.yml" "$SCRIPTPATH/deployment.yml"
sed -i "s/XXXXXX/$CASS_USER/" "$SCRIPTPATH/deployment.yml"
sed -i "s/YYYYYY/$CASS_PASS/" "$SCRIPTPATH/deployment.yml"
kubectl apply -f "$SCRIPTPATH/deployment.yml"
NAME=$(kubectl get pods -l app=spring -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME
echo "============================"
kubectl apply -f "$SCRIPTPATH/service.yml"