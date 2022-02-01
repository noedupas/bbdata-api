## Prerequisites

* Docker

## Installation

simply run `docker-compose up` on the root project folder and wait for all components to be ready. Then you can use http://localhost:8080 to interract with the BBData API.

## Custom componant

If you want to edit a component of BBData, you can go to the component's folder and read the README of the component to understand his behaviour:

- [Cassandra](./cassandra/README.md)
- [MySQL](./mysql/README.md)
- [Spring API](./spring/README.md)
- [Node.js](./admin-webapp/README.md)
- [Monitoring (not used in current compose)](./monitoring/README.md)


Once you have successfully changed the componant, do not forget to rebuild a new image of the componant who will be used by docker-compose for the container creation
(with cassandra, since the image is built from the DOCKERFILE himself, there is no need to update the image manually).