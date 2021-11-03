# Cassandra schema

This folder contains the structure of the cassandra database required for BBData, as well as dockerfiles and data for testing purposes. 

### Cassandra schema

In production, you only need the schema definition, that you can find in `bootstrap_data/schema.cql`.


### Dev setup (docker)

__Important__: if you change the structure or test data (`bootstrap_data/*.cql`), you need to rebuild the image !

Build or run the container with docker-compose on the root structure of the project:

* ```docker-compose build```
* ```docker-compose up```

Connect:
```bash
docker exec -it bbCassandra cqlsh
```

If you want more information on how I fixed the problem of initializing the Cassandra container,
have a look at [this gist](https://gist.github.com/derlin/0d4c98f7787140805793d6268dae8440).