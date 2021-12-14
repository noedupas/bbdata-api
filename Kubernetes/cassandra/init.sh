#!/bin/bash

echo "============================"
sleep 1

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
COUNT=$(expr $(kubectl -n cert-manager get pods | wc -l) - 2)
for i in `seq 0 $COUNT`
do
    NAME=$(kubectl -n cert-manager get pods -o "jsonpath={.items[$i].metadata.name}")
    kubectl -n cert-manager wait --for=condition=ready pod $NAME
done
echo "============================"
sleep 2


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/default
NAME=$(kubectl -n cass-operator get pods -o "jsonpath={.items[0].metadata.name}")
kubectl -n cass-operator wait --for=condition=ready pod $NAME
echo "============================"


kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster
echo "============================"


SCNAME=$(kubectl get sc -o "jsonpath={.items[0].metadata.name}")
cp cassdc1_orig.yml cassdc1.yml
sed -i "s/XXXXXX/$SCNAME/" cassdc1.yml
kubectl -n cass-operator apply -f cassdc1.yml
echo "============================"

export STATUS="XXXXX"
while [ $STATUS != "Ready" ]
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


export OPERATION="CREATE SCHEMA bbdata2 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e \"$OPERATION\""
echo "============================"
export OPERATION="CREATE TABLE bbdata2.raw_values (object_id int, timestamp timestamp, comment text, month text, value text, PRIMARY KEY ((object_id, month), timestamp)) WITH CLUSTERING ORDER BY (timestamp ASC);"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e \"$OPERATION\""
echo "============================"
export OPERATION="CREATE TABLE bbdata2.aggregations (minutes int, object_id int, date text, timestamp timestamp, last float, last_ts bigint, min float, max float, sum float, mean float, count int, k float, k_sum float, k_sum_2 float, std float, PRIMARY KEY ((minutes, object_id, date), timestamp)) WITH CLUSTERING ORDER BY (timestamp DESC);"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e \"$OPERATION\""
echo "============================"
export OPERATION="CREATE TABLE bbdata2.objects_stats_counter (object_id int, n_reads counter, n_values counter, PRIMARY KEY (object_id));"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e \"$OPERATION\""
echo "============================"
export OPERATION="CREATE TABLE bbdata2.objects_stats (object_id int, avg_sample_period float, last_ts timestamp, PRIMARY KEY (object_id));"
kubectl -n cass-operator exec -ti cluster1-dc1-default-sts-0 -c cassandra -- sh -c "cqlsh -u '$CASS_USER' -p '$CASS_PASS' -e \"$OPERATION\""
echo "============================"

# IP: cluster1-dc1-service ?? https://github.com/k8ssandra/cass-operator/blob/master/docs/user/README.md