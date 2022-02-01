#!/usr/bin/env bash

# Create topic if not exist
if ! kafka-topics.sh --list --bootstrap-server kafka:9092 | grep bbdata2-augmented; then
    kafka-topics.sh --create --bootstrap-server kafka:9092 --replication-factor 1 --partitions 1 --topic bbdata2-augmented
fi

# Consume message in order to print them in console
kafka-console-consumer.sh --bootstrap-server kafka:9092 --topic bbdata2-augmented