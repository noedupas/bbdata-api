#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: "bukibarak.ch/v1"
  kind: BBData
  executeHookOnEvent:
  - Deleted
EOF
else
  type=$(jq -c -r '.[0].type' $BINDING_CONTEXT_PATH)
  if [[ $type == "Event" ]] ; then
    namespace=$(jq -c -r '.[0].object.metadata.namespace' $BINDING_CONTEXT_PATH)

    kubectl -n bbdata-operator annotate pods bbdata-operator status="Deleting deployment" --overwrite=true
    kubectl -n $namespace delete cassdcs datacenter1 # Delete Cassandra Datacenter
    kubectl -n kafka delete Kafka my-cluster-$namespace # Delete Kafka cluster
    kubectl -n $namespace delete deployment mysql # Delete MySQL Deployment (pods)
    kubectl -n $namespace delete pvc mysql-pv-claim-$namespace # Delete MySQL Volume
    kubectl -n $namespace delete pv mysql-pv-volume-$namespace # Delete MySQL Volume
    kubectl -n $namespace delete ConfigMap mysql-initdb-config
    kubectl -n $namespace delete service mysql # Delete MySQL Service
    kubectl -n $namespace delete deployment spring # Delete Spring Deployment (pods)
    kubectl -n $namespace delete service spring # Delete Spring Service
    kubectl -n $namespace delete deployment nodejs # Delete Node.js Deployment (pods)
    kubectl -n $namespace delete service nodejs # Delete Node.js Service

    kubectl -n $namespace wait cassdcs/datacenter1 --for=delete --timeout=60s
    kubectl -n kafka wait Kafka/my-cluster-$namespace --for=delete --timeout=60s
    kubectl -n $namespace wait deployment/mysql --for=delete --timeout=60s
    kubectl -n $namespace wait service/mysql --for=delete --timeout=60s
    kubectl -n $namespace wait deployment/spring --for=delete --timeout=60s
    kubectl -n $namespace wait service/spring --for=delete --timeout=60s
    kubectl -n $namespace wait deployment/nodejs --for=delete --timeout=60s
    kubectl -n $namespace wait service/nodejs --for=delete --timeout=60s

    kubectl -n bbdata-operator annotate pods bbdata-operator status="Not deployed" --overwrite=true
  fi
fi