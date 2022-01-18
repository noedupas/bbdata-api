#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  echo '{"configVersion":"v1", "onStartup": 5}'
else
  # Check if default replica env variable is set and set it to 1 otherwise
  if [[ -z "${DEFAULT_REPLICA_SET}" ]]; then
    export DEFAULT_REPLICA_SET=1
  fi

  # Check if WebApp replica env variable is set and set it to default value otherwise
  if [[ -z "${WEBAPP_REPLICA_SET}" ]]; then
    export WEBAPP_REPLICA_SET=$DEFAULT_REPLICA_SET
  fi

  # Get the template path for Node.js
  FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/node"

  # Set the replica set for the Node.js deployment
  sed -i "s/WEBAPP_REPLICA_SIZE/$WEBAPP_REPLICA_SET/" "$FILEPATH/deployment.yml"

  # Deploy the WebApp server and wait for it to be ready
  kubectl apply -f "$FILEPATH/deployment.yml"
  NAME=$(kubectl get pods -l app=nodejs -o "jsonpath={.items[0].metadata.name}")
  kubectl wait --for=condition=ready pod $NAME

  # Deploy the Node.js service
  kubectl apply -f "$FILEPATH/service.yml"
fi