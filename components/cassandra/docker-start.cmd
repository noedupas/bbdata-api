@echo off
docker run --rm -p 9042:9042 --name bbcassandra-single bbdata-cassandra
pause