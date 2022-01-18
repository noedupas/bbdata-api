#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  echo '{"configVersion":"v1", "onStartup": 3}'
else

  # Get the template path for mysql
  FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/mysql"

  # Deploy MySQL and wait for it to be ready
  kubectl apply -f "$FILEPATH/deployment.yml"
  NAME=$(kubectl get pods -l app=mysql -o "jsonpath={.items[0].metadata.name}")
  kubectl wait --for=condition=ready pod $NAME
fi