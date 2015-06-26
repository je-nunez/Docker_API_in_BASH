
# does expect DOCKER_CERT_PATH
# checks whether DOCKER_TLS_VERIFY is non-zero or not

container_id=a_container_hexadecimal_id
V_DOCKER_IP=my_docker_service_ip   # either from $DOCKER_HOST or from $(boot2docker ip), etc
V_DOCKER_PORT=my_docker_service_port   # from $DOCKER_HOST, etc


if [[ "$DOCKER_TLS_VERIFY" != "0" ]]; then
   transport_cmd="openssl s_client -cert  $DOCKER_CERT_PATH/cert.pem  -key   $DOCKER_CERT_PATH/key.pem  -CAfile  $DOCKER_CERT_PATH/ca.pem   -host  $V_DOCKER_IP  -port  $V_DOCKER_PORT -no_ssl2 -quiet "
else
   transport_cmd="nc  $V_DOCKER_IP  $V_DOCKER_PORT"
   # Using socat instead, if available
   # transport_cmd="socat - tcp:$V_DOCKER_IP:$V_DOCKER_PORT"
fi

json_fmt="python -m json.tool"


# PING the docker service (answer is not in JSON format)

echo -e  "GET /_ping HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d'

# Get info of the Docker service

echo -e  "GET /info HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Get list of Docker images

echo -e  "GET /images/json HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Get list of Docker containers

echo -e  "GET /containers/json?all=1 HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Inspect a container's settings

echo -e  "GET /containers/${container_id}/json HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Retrieve a container logs, with timestamps=1 (answer is not in JSON format)

echo -e  "GET /containers/${container_id}/logs?stderr=1&stdout=1&timestamps=1 HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d'

# PS of processes running inside a container (with ps_args=auxwww)

echo -e  "GET /containers/${container_id}/top?ps_args=auxwww HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Changes done by its filesystem during the running of a container

echo -e  "GET /containers/${container_id}/changes HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | $json_fmt

# Get TAR-BALL image of a container (answer is not in JSON format)

echo -e  "GET /containers/${container_id}/export HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d'

# Get kernel stats for the container (it is a continuous stream, hence head -n 1)

echo -e  "GET /containers/${container_id}/stats?stream=0 HTTP/1.0\r\nHost: $V_DOCKER_IP:$V_DOCKER_PORT\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n"   | $transport_cmd 2>/dev/null | sed '1,/^'$'\r''$/d' | head -n 1 | $json_fmt

