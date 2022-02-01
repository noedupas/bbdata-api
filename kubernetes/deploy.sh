#!/bin/bash

k3d cluster delete myCluster
k3d cluster create myCluster -p "8080-8088:30080-30088@agent:0" -a 2

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

# Deploy the kafka operator
kubectl create namespace kafka
kubectl -n kafka create -f https://strimzi.io/install/latest?namespace=kafka

kubectl apply -f bbdata-operator.yml
sleep 15
kubectl apply -f bbdata-deployment.yml
kubectl -n bbdata-operator logs -f po/bbdata-operator