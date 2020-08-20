# BBData API

![Build & Tests](https://github.com/big-building-data/bbdata-api/workflows/Build/badge.svg)

This repository is the cornerstone of BBData. It contains: 

1. a SpringBoot Application exposing a REST API for submitting measures, administering objects, users, etc.
2. dockerfiles and docker-compose for local testing, including: MySQL, Cassandra, Kafka
3. the definition of the two databases at the center of BBData: MySQL & Cassandra



- [Development setup](#development-setup)
  * [Prerequisites](#prerequisites)
  * [Setup](#setup)
  * [Cassandra, MySQL and Kafka](#cassandra--mysql-and-kafka)
  * [Profiles](#profiles)
  * [Hidden system variables](#hidden-system-variables)
- [Production](#production)
  * [Minimal properties to provide](#minimal-properties-to-provide)
  * [Executing the jar](#executing-the-jar)
  * [Caching](#caching)
- [Permission system](#permission-system)
    
## Development setup

### Prerequisites

* Java 1.8+
* IntelliJ IDE with Kotlin support
* Docker

### Setup

Open the project in IntelliJ and let it work. Once finished, you should be able to simply run the app by 
launching the main class `ch.derlin.bbdata.BBDataApplication` (open it and right-click > run).

Of course, you will need MySQL, Cassandra and Kafka running for the whole API to run (to skip some of those deps, 
the the Profiles section).

### Cassandra, MySQL and Kafka

To setup the three dependant services, have a look at the `other` folder.
It contains all the files needed for a production setup, as well as instruction on how to run a Docker container
for local dev/testing.

### Profiles

By default, the app will launch with everything turned on, and will try to connect to MySQL, Cassandra and Kafka on localhost
on default ports (see `src/main/resources/application.properties`).

Profiles let you disable some parts of the application. This is very useful for quick testing.
To enable specific profiles, use the `-Dspring.profiles.active=XX[,YY]` JVM argument.
On IntelliJ: _Edit Configurations ... > VM Options_.


Currently available profiles (see the class `ch.derlin.bbdata.api.Profiles`):

* `unsecured`: all endpoints will be available without apikeys; the userId is automatically set to `1`;
* `input`: will only register the "input" endpoint (`POST /objects/values`);
* `output`: will only register the "output" endpoints (everything BUT the one above);
* `noc`: short for "_No Cassandra_". It won't register endpoints needing a Cassandra connection (input and values);
* `sqlstats`: use MySQL to store objects statistics, instead of Cassandra

Profiles can be combined (when it makes sense).

__Examples__:

Output only:
```bash
java -jar bbdata.jar -Dspring.profiles.active=output
```

Output only, no security checks:
```bash
java -jar bbdata.jar -Dspring.profiles.active=output,unsecured
```

Output only, no security checks and no cassandra
(note that the output profile is not needed, as no Cassandra means no input):
```bash
java -jar bbdata.jar -Dspring.profiles.active=noc,unsecured
```

### Hidden system variables

There are two system variables that can be set (`export XX=YY`), mostly for use in tests:

* `BB_NO_KAFKA=<bool>`: this turns off the publication of augmented values to kafka in the input endpoint. Useful when we don't want to spawn a Kafka container.
* `UNSECURED_BBUSER=<int>`: this determines which `userId` is used as default when the `UNSECURED` profile is turned off. Default to 1.

In test files, those variables can be set using the `@SpringBootTest` annotation, e.g.:
```
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT, properties = arrayOf("UNSECURED_BBUSER=2"))
```

## Production

To deploy in production, you need to build the jar and override some properties in order to connect to the correct services.

1. to build the jar: `./gradlew bootJar`, the jar will be created as `./build/libs/*.jar`
2. to specify properties from a file outside the jar: https://www.baeldung.com/spring-properties-file-outside-jar

### Minimal properties to provide

Here is a sample file, values to change are in UPPERCASE:
```properties
## MySQL properties
spring.datasource.url = jdbc:mysql://HOST:PORT/bbdata2?autoReconnect=true&useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=bbdata-admin
spring.datasource.password=PASSWORD

## Cassandra properties
spring.data.cassandra.contact-points=IP_1,IP_2,IP_X
spring.data.cassandra.consistency-level=quorum

## Kafka properties
spring.kafka.producer.bootstrap-servers=HOST:PORT
spring.kafka.template.default-topic=bbdata2-augmented
```

### Executing the jar

The jar is fully executable, meaning you can do:

```bash
# default
./bbdata-api-*.jar

# with profiles: no "-D", but "--" instead !
./bbdata-api-*.jar --spring.profiles.active=unsecured,noc
```

Or, you can use the old school way:
```bash
# default
java -jar bbdata-api-*.jar

# with profiles: no -D !
java -Dspring.profiles.active=unsecured,noc -jar bbdata-api-*.jar
```

### Caching

Caching is interesting in one part of the application, namely the input endpoint `POST /values`. 
The application needs to fetch the metadata associated to an object (and a token) on each request. 
To speed it up, the application can be configured to cache those metadata using either an in-memory concurrent hashmap,
or an external database such as redis.

**To enable caching**, set the `caching` active profile. It will use in-memory caching by default (`simple`). 
To use another caching strategy, use the property `spring.cache.type=redis|simple|none` (none = no cache).
Note that `none` doesn't disable caching, just ensures nothing is actually put into the cache.
Example:
```
./bbdata-api-*.jar --spring.profiles.active=caching
```


Redis default properties are shown below (can be overriden from a property file). To use redis, activate the `caching` profile
and set `spring.cache.type=redis`:

```properties
# To actually use redis cache, enable caching through the caching profile and uncomment this line:
#spring.cache.type=redis
spring.redis.host=localhost
spring.redis.port=6379
```

**IMPORTANT**: in case you deploy the input api and the output api separately (using profiles), 
YOU NEED TO USE AN EXTERNAL CACHE (e.g. redis). This is because the output API is responsible for evicting old entries
from the cache. If the input and the output do not run in the same JVM, the cache strategy `simple` is *dangerous*:
the input api won't see if a token gets deleted, or if an object becomes disabled.

Current caching strategy:

* one cache is used with the name `metas`,
* metadata needed by the input api (unit, object owner, object state, object type, etc) get cached with a key `objectId:token`,
* the cache is not updated when an object name or description changes (not really used by any downstream steps),
* a single cache entry gets evicted when a token is deleted,
* the entire cache is flushed when an object changes state (enabled/disabled), this is because we use compound keys,
  and have no way of using wildcard (e.g. `objectId:*`) in `@CacheEvict`. However, this operation is usually rare. 


## Permission system

📛 **tldr; IMPORTANT** 📛 Ensure that the `userGroup` with ID 1 has a meaningful name in the database (e.g. "admin") and that
you only add the platform managers to it !

The permission system in BBData uses mappings between userGroups and objectGroups.

A user can be part of one or more userGroups, either as regular user or as admin. 
Objects can be part of one or more objectGroups. 
ObjectGroups have a list of allowed userGroups (defining read permissions to objects that belong to it), 
and a single owner, which is the userGroup that created it. 
Only admin users from the owning userGroup can manage objects and permissions of an objectGroup.
Regular users can access them in read mode.
This is the same for objects: admins of the owning group has write access (e.g. editing metadata), 
regular users only read access (e.g. getting values).

There is one special case: the userGroup with `userGroupId=1` is the *🔱SUPERADMIN🔱 group*.
This is the equivalent of `SUDO`: any admin of this group has read/write access to ANY resource, in read and write mode. 

(see the documentation for more info)