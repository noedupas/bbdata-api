## Prerequisites
- [Docker](https://docs.docker.com/get-docker/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) with a Kubernetes environment

## Build

If you change some files in `hooks`, `scripts` or `templates` folders or if you change the `Dockefile`,
you must re-build and push the bbdata-operator:

```console
$ docker build -t "registry.mycompany.com/bbdata-operator:v1" .
$ docker push "registry.mycompany.com/bbdata-operator:v1"
```

Then, you'll need to change the `image` name of the operator pod in [bbdata-operator.yml](bbdata-operator.yml#L88), line 88.

Once you deploy the operator, use your custom bbdata-operator.yml file to apply your modifications.

## Deploy

### Cassandra operator

For this projet, you need to have the [k8ssandra cass-operator](https://github.com/k8ssandra/cass-operator) deployed in your kubernetes cluster.

A simple way to deploy the cass-operator is by running this script:

```console
$ # Deploy cert-manager on the Kubernetes environnment as this is required for the cass-operator to work
$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml
$ 
$ # Wait for cert-manager deployment
$ COUNT=$(expr $(kubectl -n cert-manager get pods | wc -l) - 2)
$ for i in `seq 0 $COUNT`
$ do
$     NAME=$(kubectl -n cert-manager get pods -o "jsonpath={.items[$i].metadata.name}")
$     kubectl -n cert-manager wait --for=condition=ready pod $NAME
$ done
$ sleep 5
$ 
$ # Deploy the cass-operator on the Kubernetes environnment and wait for the deployment to be done
$ kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/default
$ NAME=$(kubectl -n cass-operator get pods -o "jsonpath={.items[0].metadata.name}")
$ kubectl -n cass-operator wait --for=condition=ready pod $NAME
$ 
$ # Deploy the cass-operator default cluster
$ kubectl apply -k github.com/k8ssandra/cass-operator/config/deployments/cluster
```

This script will deploy a default configuration of the cert-manager and the cass-operator operators. 

### Kafka operator

For this projet, you need to have the [strimzi operator](https://strimzi.io/) deployed in your kubernetes cluster.

You can deploy the strimzi operator by running (change STRIMZI-NAMESPACE by the name of the namespace you want to use):

```console
$ kubectl -n STRIMZI-NAMESPACE create -f https://strimzi.io/install/latest?namespace=STRIMZI-NAMESPACE
```

**IMPORTANT:** By default, the opertor will only listen for Kafka/ZooKeeper CRD on the namespace where the operator is deployed.
This means that you need to deploy the Kafka cluster used by BBData on the same namespace as the Strimzi operator. 
You can do this by providing a different namespace for the Kafka cluster when you create the BBData CRD, as below.

Or, you can deploy a custom version of the strimzi operator who'll listen on the BBData namespace. To do this, please read [this article](https://strimzi.io/docs/0.16.2/full.html#deploying-cluster-operator-to-watch-multiple-namespacesstr).


### BBData operator

In order to deploy the BBData operator, simply run :

```console
$ kubectl apply -f https://raw.githubusercontent.com/bukibarak/bbdata-api/dev/bbdata-operator/bbdata-operator.yml
```

## Install

You can edit `bbdata-deployment.yml` spec in order to deploy an application matching your requirements. Here is a list of all available specs:
- `defaultReplica`: The default amount for each component, if not specified (default value: `1`). This does not concern MySQL and Node.js who are deployed only once.
- `cassandraReplica`: The amount of Cassandra replica. WARNING: The value **must** be lower or equal to the amount of available Kubernetes agent nodes in the cluster.
- `kafkaReplica`: The maximum amount of Kafka/Zookeper replica (those componants are auto-scaled).
- `bbdataReplica`: The amount of BBData API replica, which means the amount of Spring API replica.
- `cassandraStorageClass`: The name of the Kubernetes StorageClass used by cassandra (default value: the name of the 1st StorageClass found). See more: [Cass-operator](https://github.com/k8ssandra/cass-operator#creating-a-storage-class), [Kubernetes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- `bbdataNodePort`: The port forwarded to access the BBData API from outside the kubernetes cluster (default: 30080)
- `webappNodePort`: The port forwarded to access the Node.js WebApp from outside the kubernetes cluster (default: 30088)
- `kafkaNamespace`: The namespace where the Kafka cluster will be crated. Be sure that the namespace is listened by the strimzi operator (default: namespace where the CRD is deployed)

Once all is set, run:

```console
$ kubectl apply -f bbdata-deployment.yml
```

## Logging

You can see the logs of the operator by running:

```console
$ kubectl -n bbdata-operator logs -f po/bbdata-operator
```

You can also get the status of the operator by running:

```console
$ kubectl -n bbdata-operator get pod bbdata-operator -o "jsonpath={.metadata.annotations.status}"
```

Available status:
- `Initialize deployment`: The operator is initializing the BBData deployment.
- `Deploying Cassandra`: The operator is deploying Cassandra using k8ssandra operator.
- `Deploying Kafka`: The operator is deploying Kafka and ZooKeeper using stimzi operator.
- `Deploying MySQL`: The operator is deploying MySQL with the BBData structure.
- `Deploying Spring API`: The operator is deploying the BBData API.
- `Deploying WebApp`: The operator is deploying the Node.js WebApp.
- `Running`: The BBData application is running.
- `Deleting deployment`: The BBData deployment is being deleted.
- `Not deployed`: The BBData deployment have successfuly been deleted, the application is no more deployed.


## Cleanup

```console
$ kubectl delete BBData <BBDATA_NAME>
$ kubectl delete ns/bbdata-operator
$ kubectl delete ns/cass-operator
$ kubectl delete ns/cert-manager
$ kubectl delete ns/kafka
$ docker rmi "registry.mycompany.com/bbdata-operator:v1"
```
