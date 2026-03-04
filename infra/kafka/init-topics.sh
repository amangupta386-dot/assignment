#!/bin/sh
set -e

kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic user-events --partitions 3 --replication-factor 1
kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic worker-events --partitions 3 --replication-factor 1
kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic job-events --partitions 6 --replication-factor 1
kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic payment-events --partitions 3 --replication-factor 1
kafka-topics --bootstrap-server kafka:9092 --create --if-not-exists --topic notification-events --partitions 3 --replication-factor 1
