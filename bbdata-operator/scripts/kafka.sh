#!/usr/bin/env bash


# Get the template path for kafka
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/kafka"

# Deploy the kafka operator
kubectl create namespace kafka
kubectl -n kafka create -f https://strimzi.io/install/latest?namespace=kafka

# Set the minimum replica set according to the env variable
if [[ $KAFKA_REPLICA_SET -le 2 ]] ; then
    KAFKA_MIN=1
else
    KAFKA_MIN=$(($KAFKA_REPLICA_SET - 1))
fi

# Deploy the kafka persistant cluster and wait for it to be ready
cp "$FILEPATH/cluster.yml" "$FILEPATH/cluster_deploy.yml"
sed -i "s/KAFKA_REPLICA_SIZE/$KAFKA_REPLICA_SET/" "$FILEPATH/cluster_deploy.yml"
sed -i "s/KAFKA_MIN_REPLICA_SIZE/$KAFKA_MIN/" "$FILEPATH/cluster_deploy.yml"
sed -i "s/NAMESPACE/$namespace/" "$FILEPATH/cluster_deploy.yml"
kubectl -n kafka apply -f "$FILEPATH/cluster_deploy.yml"
kubectl wait kafka/my-cluster-$namespace --for=condition=Ready --timeout=300s -n kafka