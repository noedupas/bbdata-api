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
    kubectl -n bbdata-operator annotate pods bbdata-operator status="Deleting deployment" --overwrite=true
    kubectl -n bbdata delete all --all
    kubectl delete namespace bbdata
    kubectl -n kafka delete all --all
    kubectl delete namespace kafka
    kubectl delete cassdcs --all-namespaces --all
    kubectl -n cass-operator delete all --all
    kubectl delete namespace cass-operator
    kubectl -n cert-manager delete all --all
    kubectl delete namespace cert-manager

    sleep 15
    terminating=$(kubectl get namespaces -o "jsonpath={.items}" --field-selector="status.phase=Terminating" | jq length)
    while [[ $terminating -ne 0 ]]
    do
      names=$(kubectl get namespaces -o "jsonpath={.items[*].metadata.name}" --field-selector="status.phase=Terminating")
      echo "Waiting for following namespaces to be deleted: $names"
      sleep 5
      terminating=$(kubectl get namespaces -o "jsonpath={.items}" --field-selector="status.phase=Terminating" | jq length)
    done

    kubectl -n bbdata-operator annotate pods bbdata-operator status="Not deployed" --overwrite=true
  fi
fi