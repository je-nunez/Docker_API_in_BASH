#!/usr/bin/env bash

# Cheat-sheet to interact with the Docker API low-level, ie., using
# tools like 'netcat' or 'openssl s_client'

# does expect DOCKER_CERT_PATH
# checks whether DOCKER_TLS_VERIFY is non-zero or not

V_DOCKER_IP=my_docker_service_ip   # either from $DOCKER_HOST or
                                   # from $(boot2docker ip), etc
V_DOCKER_PORT=my_docker_service_port   # from $DOCKER_HOST, etc


# Source the library with our Docker utility functions

. ./docker_low_level_library.sh

# PING the docker service

docker_ping

# Get info of the Docker service

docker_daemon_info

# Get list of Docker images

docker_list_images

# Get list of Docker containers

docker_list_containers

# Inspect a container's settings

docker_inspect_container   "${container_id}"

# Retrieve a container logs, with timestamps=1 (answer is not in JSON format)

docker_logs_container "${container_id}"

# PS of processes running inside a container

docker_ps_container "${container_id}"

# Changes done by its filesystem during the running of a container

docker_diff_changes_container "${container_id}"

# Get TAR-BALL image of a container (answer is not in JSON format)

docker_save_tar_ball "${container_id}"

# Get kernel stats for the container

docker_kernel_stats "${container_id}"

