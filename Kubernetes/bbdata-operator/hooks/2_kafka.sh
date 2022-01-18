#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  echo '{"configVersion":"v1", "onStartup": 2}'
else
  # Check if default replica env variable is set and set it to 1 otherwise
  if [[ -z "${DEFAULT_REPLICA_SET}" ]]; then
    DEFAULT_REPLICA_SET=1
  fi

  # Check if kafka replica env variable is set and set it to default value otherwise
  if [[ -z "${KAFKA_REPLICA_SET}" ]]; then
    export KAFKA_REPLICA_SET=$DEFAULT_REPLICA_SET
  fi

  # Get the template path for kafka
  FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/kafka"

  # Deploy the kafka operator
  kubectl create namespace kafka
  kubectl -n kafka create -f 'https://strimzi.io/install/latest?namespace=kafka' 

  # Set the minimum replica set according to the env variable
  if [[ $KAFKA_REPLICA_SET -le 2 ]] ; then
      KAFKA_MIN=1
  else
      KAFKA_MIN=$(($KAFKA_REPLICA_SET - 1))
  fi

  # Deploy the kafka persistant cluster and wait for it to be ready
  sed -i "s/KAFKA_REPLICA_SIZE/$KAFKA_REPLICA_SET/" "$FILEPATH/cluster.yml"
  sed -i "s/KAFKA_MIN_REPLICA_SIZE/$KAFKA_MIN/" "$FILEPATH/cluster.yml"
  kubectl -n kafka apply -f "$FILEPATH/cluster.yml"
  kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka 
fi