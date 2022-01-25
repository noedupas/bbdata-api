#!/usr/bin/env bash


# Get the template path for spring
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/spring"

# Get the cassandra user, password and host
CASS_USER=$(kubectl -n cass-operator get secret cluster1-superuser -o "jsonpath={.data.username}" | base64 -d)
CASS_PASS=$(kubectl -n cass-operator get secret cluster1-superuser -o "jsonpath={.data.password}" | base64 -d)

# Set the replica set and the cassandra username and password for the Spring deployment
sed -i "s/BBDATA_REPLICA_SIZE/$BBDATA_REPLICA_SET/" "$FILEPATH/deployment.yml"
sed -i "s/CASS_USERNAME/$CASS_USER/" "$FILEPATH/deployment.yml"
sed -i "s/CASS_PASSWORD/$CASS_PASS/" "$FILEPATH/deployment.yml"

# Deploy the Spring BBData API and wait for it to be ready
kubectl apply -f "$FILEPATH/deployment.yml"
NAME=$(kubectl get pods -l app=spring -o "jsonpath={.items[0].metadata.name}")
kubectl wait --for=condition=ready pod $NAME

# Deploy the Spring service
kubectl apply -f "$FILEPATH/service.yml"