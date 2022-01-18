#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
COUNT=$(expr $(kubectl -n cert-manager get pods | wc -l) - 2)
for i in `seq 0 $COUNT`
do
    NAME=$(kubectl -n cert-manager get pods -o "jsonpath={.items[$i].metadata.name}")
    kubectl -n cert-manager wait --for=condition=ready pod $NAME
done
echo "============================"
sleep 5


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/default
NAME=$(kubectl -n cass-operator get pods -o "jsonpath={.items[0].metadata.name}")
kubectl -n cass-operator wait --for=condition=ready pod $NAME
echo "============================"


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster
echo "============================"


SCNAME=$(kubectl get sc -o "jsonpath={.items[0].metadata.name}")
cp "$SCRIPTPATH/cassdc1_orig.yml" "$SCRIPTPATH/cassdc1.yml"
sed -i "s/XXXXXX/$SCNAME/" "$SCRIPTPATH/cassdc1.yml"
kubectl -n cass-operator apply -f "$SCRIPTPATH/cassdc1.yml"
echo "============================"


export STATUS="XXXXXX"
while [[ $STATUS != "Ready" ]]
do
    sleep 5
    STATUS=$(kubectl -n cass-operator get cassdc/datacenter1 -o "jsonpath={.status.cassandraOperatorProgress}")
    echo $STATUS
done
echo "============================"


CASS_USER=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.username' | base64 --decode)
CASS_PASS=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.password' | base64 --decode)
CASS_HOST=$(kubectl -n cass-operator get services -o "jsonpath={.items[1].metadata.name}")
echo "User: $CASS_USER"
echo "Pssw: $CASS_PASS"
echo "Host: $CASS_HOST"
echo "---------------------------"

cp "$SCRIPTPATH/bbdata-schema_orig.yml" "$SCRIPTPATH/bbdata-schema.yml"
sed -i "s/XXXXXX/$CASS_USER/" "$SCRIPTPATH/bbdata-schema.yml"
sed -i "s/YYYYYY/$CASS_PASS/" "$SCRIPTPATH/bbdata-schema.yml"
sed -i "s/ZZZZZZ/$CASS_HOST/" "$SCRIPTPATH/bbdata-schema.yml"
kubectl -n cass-operator apply -f "$SCRIPTPATH/bbdata-schema.yml"
kubectl -n cass-operator wait --for=condition=complete job/schema
