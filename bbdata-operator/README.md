## Prerequisites
- [Docker]()
- [kubectl]() with a Kubernetes environment

## Operator used

The BBData operator uses the [k8ssandra cass-operator](https://github.com/k8ssandra/cass-operator) to deploy Cassandra and [strimzi operator](https://strimzi.io/) to deploy Kafka and ZooKeeper.

## Build the operator

In case of modifications of files in `hooks`, `scripts` or `templates` folders or the `Dockefile`, 
you must re-build and push the bbdata-operator:

```
$ docker build -t "registry.mycompany.com/bbdata-operator:v1" .
$ docker push "registry.mycompany.com/bbdata-operator:v1"
```

## Deploy

If you want to use a custom image of the operator (if you edited the files mentionned in the previous section),
you'll need to change the `image` name of the operator pod in [bbdata-operator.yml](bbdata-operator.yml#L82), line 82.

You can edit `bbdata-deploy.yml` spec in order to deploy an application matching your requirements. Here is a list of all available specs:
- `defaultReplica`: The default amount for each component, if not specified (default value: `1`). This does not concern MySQL and Node.js who are deployed only once.
- `cassandraReplica`: The amount of Cassandra replica. WARNING: The value **must** be lower or equal to the amount of available Kubernetes agent nodes in the cluster.
- `kafkaReplica`: The maximum amount of Kafka/Zookeper replica (those componants are auto-scaled).
- `bbdataReplica`: The amount of BBData API replica, which means the amount of Spring API replica.
- `cassandraStorageClass`: The name of the Kubernetes StorageClass used by cassandra (default value: the name of the 1st StorageClass found). See more: [Cass-operator](https://github.com/k8ssandra/cass-operator#creating-a-storage-class), [Kubernetes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

Once all is set, run:

```
$ kubectl apply -f bbdata-operator.yml
$ kubectl apply -f bbdata-operator.yml
```

## Logging

You can see the logs of the operator by running:

```
$ kubectl -n bbdata-operator logs -f po/bbdata-operator
```

You can also get the status of the operator by running:

```
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

```
$ kubectl delete BBData <BBDATA_NAME>
$ kubectl delete ns/bbdata-operator
$ docker rmi "registry.mycompany.com/bbdata-operator:v1"
```
