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

# Deploy cert-manager on the Kubernetes environnment as this is required for the cass-operator to work
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml

# Wait for cert-manager deployment
COUNT=$(expr $(kubectl -n cert-manager get pods | wc -l) - 2)
for i in `seq 0 $COUNT`
do
    NAME=$(kubectl -n cert-manager get pods -o "jsonpath={.items[$i].metadata.name}")
    kubectl -n cert-manager wait --for=condition=ready pod $NAME
done
sleep 5

# Deploy the cass-operator on the Kubernetes environnment and wait for the deployment to be done
kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/default
NAME=$(kubectl -n cass-operator get pods -o "jsonpath={.items[0].metadata.name}")
kubectl -n cass-operator wait --for=condition=ready pod $NAME

# Deploy the cass-operator default cluster
kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster

# Change values in the dc1 file to the env variable given values
sed -i "s/CASS_REPLICA_SIZE/$CASSANDRA_REPLICA_SET/" "$FILEPATH/dc1.yml"
sed -i "s/CASS_SC_NAME/$CASSANDRA_STORAGECLASS_NAME/" "$FILEPATH/dc1.yml"

# Deploy the cassandra datacenter and wait for it to be ready. THIS ACTION MAY TAKE VERY LONG TIME
kubectl -n cass-operator apply -f "$FILEPATH/dc1.yml"

export STATUS="Unknown"
while [[ $STATUS != "Ready" ]]
do
    sleep 5
    STATUS=$(kubectl -n cass-operator get cassdc/datacenter1 -o "jsonpath={.status.cassandraOperatorProgress}")
    echo "Waiting for cassandra datacenter deployment - Status: $STATUS"
done
echo "Done !"

# Get the cassandra user, password and host
CASS_USER=$(kubectl -n cass-operator get secret cluster1-superuser -o "jsonpath={.data.username}" | base64 -d)
CASS_PASS=$(kubectl -n cass-operator get secret cluster1-superuser -o "jsonpath={.data.password}" | base64 -d)
CASS_HOST=$(kubectl -n cass-operator get services -o "jsonpath={.items[1].metadata.name}")

# Deploy the cassandra shema to the host in order to create the BBData database structure
sed -i "s/USER_VALUE/$CASS_USER/" "$FILEPATH/schema.yml"
sed -i "s/PASS_VALUE/$CASS_PASS/" "$FILEPATH/schema.yml"
sed -i "s/HOST_VALUE/$CASS_HOST/" "$FILEPATH/schema.yml"
kubectl -n cass-operator apply -f "$FILEPATH/schema.yml"
kubectl -n cass-operator wait --for=condition=complete job/schema