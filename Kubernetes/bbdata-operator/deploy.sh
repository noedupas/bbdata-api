#!/bin/bash

k3d cluster delete myCluster
k3d cluster create myCluster -p "8080-8088:30080-30088@agent:0" -a 2
kubectl create ns bbdata-operator
kubectl -n bbdata-operator apply -f bbdata-operator-rbac.yaml
kubectl -n bbdata-operator apply -f bbdata-operator-pod.yaml
sleep 15
kubectl -n bbdata-operator logs -f po/bbdata-operator