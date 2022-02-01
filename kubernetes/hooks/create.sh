#!/usr/bin/env bash

if [[ $1 == "--config" ]] ; then
  cat <<EOF
configVersion: v1
kubernetes:
- apiVersion: "bukibarak.ch/v1"
  kind: BBData
  executeHookOnEvent:
  - Added
EOF
else
    type=$(jq -c -r '.[0].type' $BINDING_CONTEXT_PATH)

    if [[ $type == "Event" ]] ; then
      # Get the CRD specs and namespace
      specs=$(jq -c -r '.[0].object.spec' $BINDING_CONTEXT_PATH)
      export namespace=$(jq -c -r '.[0].object.metadata.namespace' $BINDING_CONTEXT_PATH)

      # Check if there is already a BBData instance deployed in the same namespace and exit if it's the case
      amount=$(kubectl -n $namespace get BBData -o "jsonpath={.items}" | jq length)
      if [[ $amount -gt 1 ]] ; then # 1 is because the BBData CRD who will be deployed is counted as well
        echo "There is already a BBData application deployed in the namespace $namespace. Please deploy the application in an other Kubernetes namespace."
        exit 0
      fi

      # Update or set the status annotation
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Initialize deployment" --overwrite=true

      # Set the env variables used in the subscripts
      export DEFAULT_REPLICA_SET=$(jq -c '.defaultReplica'  <<< $specs)
      if [[ $DEFAULT_REPLICA_SET == "null" ]] || ! [[ $DEFAULT_REPLICA_SET =~ ^[0-9]+$ ]] ; then
        export DEFAULT_REPLICA_SET=1
      fi

      export CASSANDRA_REPLICA_SET=$(jq -c '.cassandraReplica'  <<< $specs)
      if [[ $CASSANDRA_REPLICA_SET == "null" ]] || ! [[ $CASSANDRA_REPLICA_SET =~ ^[0-9]+$ ]] ; then
        export CASSANDRA_REPLICA_SET=$DEFAULT_REPLICA_SET
      fi

      export CASSANDRA_STORAGECLASS_NAME=$(jq -c '.cassandraStorageClass'  <<< $specs | tr -d '"')
      if [[ $CASSANDRA_STORAGECLASS_NAME == "null" ]] ; then
        export CASSANDRA_STORAGECLASS_NAME=$(kubectl get sc -o "jsonpath={.items[0].metadata.name}")
      fi

      export KAFKA_REPLICA_SET=$(jq -c '.kafkaReplica'  <<< $specs)
      if [[ $KAFKA_REPLICA_SET == "null" ]] || ! [[ $KAFKA_REPLICA_SET =~ ^[0-9]+$ ]] ; then
        export KAFKA_REPLICA_SET=$DEFAULT_REPLICA_SET
      fi

      export BBDATA_REPLICA_SET=$(jq -c '.bbdataReplica'  <<< $specs)
      if [[ $BBDATA_REPLICA_SET == "null" ]] || ! [[ $BBDATA_REPLICA_SET =~ ^[0-9]+$ ]] ; then
        export BBDATA_REPLICA_SET=$DEFAULT_REPLICA_SET
      fi

      export BBDATA_NODE_PORT=$(jq -c '.bbdataNodePort'  <<< $specs)
      if [[ $BBDATA_NODE_PORT == "null" ]] || ! [[ $BBDATA_NODE_PORT =~ ^[0-9]+$ ]] ; then
        export BBDATA_NODE_PORT=30080
      fi

      export WEBAPP_NODE_PORT=$(jq -c '.webappNodePort'  <<< $specs)
      if [[ $WEBAPP_NODE_PORT == "null" ]] || ! [[ $WEBAPP_NODE_PORT =~ ^[0-9]+$ ]] ; then
        export WEBAPP_NODE_PORT=30088
      fi

      export KAFKA_NAMESPACE=$(jq -c '.kafkaNamespace'  <<< $specs | tr -d '"')
      if [[ $KAFKA_NAMESPACE == "null" ]] ; then
        export KAFKA_NAMESPACE=$namespace
      fi  

      # Print the configuration to the console (for logs)
      echo "===== DEPLOYMENT CONFIGURATION ====="
      echo "DEFAULT REPLICA:   $DEFAULT_REPLICA_SET"
      echo "CASSANDRA REPLICA: $CASSANDRA_REPLICA_SET"
      echo "KAFKA REPLICA:     $KAFKA_REPLICA_SET"
      echo "BBDATA REPLICA:    $BBDATA_REPLICA_SET"
      echo "CASSANDRA SC:      $CASSANDRA_STORAGECLASS_NAME"
      echo "BBDATA NODE PORT:  $BBDATA_NODE_PORT"
      echo "WEBAPP NODE PORT:  $WEBAPP_NODE_PORT"
      echo "NAMESPACE:         $namespace"
      echo "KAFKA NAMESPACE:   $KAFKA_NAMESPACE"

      # Get the path of the script folder
      SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../scripts"

      # Call all the scripts and exit in case of failure
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Deploying Cassandra" --overwrite=true
      $SCRIPTPATH/cassandra.sh
      if [[ $? -eq 1 ]] ; then
        exit 0
      fi
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Deploying Kafka" --overwrite=true
      $SCRIPTPATH/kafka.sh
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Deploying MySQL" --overwrite=true
      $SCRIPTPATH/mysql.sh
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Deploying Spring API" --overwrite=true
      $SCRIPTPATH/spring.sh
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Deploying WebApp" --overwrite=true
      $SCRIPTPATH/node.sh
      kubectl -n bbdata-operator annotate pods bbdata-operator status="Running" --overwrite=true
    fi
fi