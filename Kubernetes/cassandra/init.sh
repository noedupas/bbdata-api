#!/bin/bash

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
COUNT=$(expr $(kubectl -n cert-manager get pods | wc -l) - 2)
for i in `seq 0 $COUNT`
do
    NAME=$(kubectl -n cert-manager get pods -o "jsonpath={.items[$i].metadata.name}")
    kubectl -n cert-manager wait --for=condition=ready pod $NAME
done
echo "============================"


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/default
echo "============================"


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster
echo "============================"


SCNAME=$(kubectl get sc -o "jsonpath={.items[0].metadata.name}")
cp cassdc1_orig.yml cassdc1.yml
sed -i "s/XXXXXX/$SCNAME/" cassdc1.yml
kubectl -n cass-operator apply -f cassdc1.yml
echo "============================"


STATUS=$(kubectl -n cass-operator get cassdc/dc1 -o "jsonpath={.status.cassandraOperatorProgress}")
while [  $STATUS != "Ready" ]
do
    sleep 5
    STATUS=$(kubectl -n cass-operator get cassdc/dc1 -o "jsonpath={.status.cassandraOperatorProgress}")
    echo $STATUS
done
echo "============================"


CASS_USER=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.username' | base64 --decode)
CASS_PASS=$(kubectl -n cass-operator get secret cluster1-superuser -o json | jq -r '.data.password' | base64 --decode)
echo "User: $CASS_USER"
echo "Pssw: $CASS_PASS"
echo "============================"


export TEST="CREATE SCHEMA bbdata2 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e '$TEST'"
echo "============================"


export TEST="CREATE SCHEMA bbdata2 WITH REPLICATION = { \'class\' : \'SimpleStrategy\', \'replication_factor\' : 3 };"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e '$TEST'"