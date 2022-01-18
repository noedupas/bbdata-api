### run

Build bbdata-operator image with custom scripts:

```
$ docker build -t "registry.mycompany.com/bbdata-operator:v1" .
$ docker push registry.mycompany.com/bbdata-operator:v1
```

Edit image in bbdata-operator-pod.yaml and apply manifests:

```
$ kubectl create ns bbdata-operator
$ kubectl -n bbdata-operator apply -f bbdata-operator-rbac.yaml
$ kubectl -n bbdata-operator apply -f bbdata-operator-pod.yaml
```

See in logs that hook.sh was run:

```
$ kubectl -n bbdata-operator logs -f po/bbdata-operator

### cleanup

```
$ kubectl delete ns/bbdata-operator
$ docker rmi registry.mycompany.com/bbdata-operator:v1
```
