#!/usr/bin/env bash


# Get the template path for spring
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/spring"

# Get the cassandra user, password and host
CASS_USER=$(kubectl -n $namespace get secret cluster1-superuser -o "jsonpath={.data.username}" | base64 -d)
CASS_PASS=$(kubectl -n $namespace get secret cluster1-superuser -o "jsonpath={.data.password}" | base64 -d)

# Set the replica set and the cassandra username and password for the Spring deployment
cp "$FILEPATH/deployment.yml" "$FILEPATH/deployment_deploy.yml"
sed -i "s/BBDATA_REPLICA_SIZE/$BBDATA_REPLICA_SET/" "$FILEPATH/deployment_deploy.yml"
sed -i "s/CASS_USERNAME/$CASS_USER/" "$FILEPATH/deployment_deploy.yml"
sed -i "s/CASS_PASSWORD/$CASS_PASS/" "$FILEPATH/deployment_deploy.yml"
sed -i "s/NAMESPACE/$namespace/" "$FILEPATH/deployment_deploy.yml"
sed -i "s/NODE_PORT/$BBDATA_NODE_PORT/" "$FILEPATH/deployment_deploy.yml"

# Deploy the Spring BBData API and wait for it to be ready
kubectl -n $namespace apply -f "$FILEPATH/deployment_deploy.yml"
NAME=$(kubectl -n $namespace get pods -l app=spring -o "jsonpath={.items[0].metadata.name}")
kubectl -n $namespace wait --for=condition=ready pod $NAME