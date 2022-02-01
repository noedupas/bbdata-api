#!/usr/bin/env bash


# Get the available amount of nodes (-1 is for the master node where pods cannot be deployed)
node_count=$(expr $(kubectl get nodes -o "jsonpath={.items[*].kind}" | wc -w) - 1)

# Check if aviable node amount is not lower than required cassandra replica set and exit application otherwise
if [[ $node_count -lt $CASSANDRA_REPLICA_SET ]] ; then
    echo "ERROR - BBData-operator: You requested for $CASSANDRA_REPLICA_SET cassandra replica set, but only $node_count nodes are available in this Kubernetes cluster."
    echo "Please add enough nodes to this Kubernetes cluster or change the CASSANDRA_REPLICA_SET env variable to a lower value."
    echo "Exiting..."
    exit 1
fi

# Get the template path for cassandra
FILEPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/../templates/cassandra"

# Change values in the dc1 file to the env variable given values
cp "$FILEPATH/dc1.yml" "$FILEPATH/dc1_deploy.yml"
sed -i "s/CASS_REPLICA_SIZE/$CASSANDRA_REPLICA_SET/" "$FILEPATH/dc1_deploy.yml"
sed -i "s/CASS_SC_NAME/$CASSANDRA_STORAGECLASS_NAME/" "$FILEPATH/dc1_deploy.yml"

# Deploy the cassandra datacenter and wait for it to be ready. THIS ACTION MAY TAKE VERY LONG TIME
kubectl -n $namespace apply -f "$FILEPATH/dc1_deploy.yml"

export STATUS="Unknown"
while [[ $STATUS != "Ready" ]]
do
    sleep 5
    STATUS=$(kubectl -n $namespace get cassdc/datacenter1 -o "jsonpath={.status.cassandraOperatorProgress}")
    echo "Waiting for cassandra datacenter deployment - Status: $STATUS"
done
echo "Done !"

# Get the cassandra user, password and host
CASS_USER=$(kubectl -n $namespace get secret cluster1-superuser -o "jsonpath={.data.username}" | base64 -d)
CASS_PASS=$(kubectl -n $namespace get secret cluster1-superuser -o "jsonpath={.data.password}" | base64 -d)
CASS_HOST=$(kubectl -n $namespace get services -o "jsonpath={.items[1].metadata.name}")

# Deploy the cassandra shema to the host in order to create the BBData database structure
cp "$FILEPATH/schema.yml" "$FILEPATH/schema_deploy.yml"
sed -i "s/USER_VALUE/$CASS_USER/" "$FILEPATH/schema_deploy.yml"
sed -i "s/PASS_VALUE/$CASS_PASS/" "$FILEPATH/schema_deploy.yml"
sed -i "s/HOST_VALUE/$CASS_HOST/" "$FILEPATH/schema_deploy.yml"
kubectl -n $namespace apply -f "$FILEPATH/schema_deploy.yml"
kubectl -n $namespace wait --for=condition=complete job/schema