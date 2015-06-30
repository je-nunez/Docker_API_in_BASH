#!/usr/bin/env bash

# Cheat-sheet to interact with the Docker API low-level, ie., using
# tools like 'netcat' or 'openssl s_client'

# does expect DOCKER_CERT_PATH
# checks whether DOCKER_TLS_VERIFY is non-zero or not

container_id=a_container_hexadecimal_id
V_DOCKER_IP=my_docker_service_ip   # either from $DOCKER_HOST or
                                   # from $(boot2docker ip), etc
V_DOCKER_PORT=my_docker_service_port   # from $DOCKER_HOST, etc


# Source the library with our Docker utility functions

. ./docker_low_level_library.sh

# Cheat-sheet

# PING the docker service (answer is not in JSON format)

Docker_API_raw_string "GET"  "/_ping" | docker_transport_cmd

# Get info of the Docker service

Docker_API_raw_string "GET"  "/info" | docker_transport_cmd | json_fmt

# Get list of Docker images

Docker_API_raw_string "GET"  "/images/json" | docker_transport_cmd | json_fmt

# Get list of Docker containers

Docker_API_raw_string "GET"  "/containers/json?all=1" | \
                         docker_transport_cmd | json_fmt

# Inspect a container's settings

Docker_API_raw_string "GET"  "/containers/${container_id}/json" | \
                         docker_transport_cmd | json_fmt

# Retrieve a container logs, with timestamps=1 (answer is not in JSON format)

Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/logs?stderr=1&stdout=1&timestamps=1" | \
                         docker_transport_cmd

# PS of processes running inside a container (with ps_args=auxwww)

Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/top?ps_args=auxwww" | \
                         docker_transport_cmd | json_fmt

# Changes done by its filesystem during the running of a container

Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/changes" | \
                         docker_transport_cmd | json_fmt

# Get TAR-BALL image of a container (answer is not in JSON format)

Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/export" | \
                         docker_transport_cmd

# Get kernel stats for the container
# (it is a continuous stream, hence 'head -n 1' below)

Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/stats?stream=0" | \
                         docker_transport_cmd | head -n 1 | json_fmt

