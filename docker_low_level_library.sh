#!/usr/bin/env bash

# does expect DOCKER_CERT_PATH
# checks whether DOCKER_TLS_VERIFY is non-zero or not

#
# Library of utility functions
#


function Docker_API_raw_string {

    # prints to standard-output the Docker API raw string we need to use

    local http_method=${1?HTTP request method expected as first parameter}
    local http_request=${2?HTTP request string expected as second parameter}


    local other_http_req_headers="Host: ${V_DOCKER_IP?}:${V_DOCKER_PORT?}\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n\r\n"

    local all_http_request="$http_method $http_request HTTP/1.0\r\n$other_http_req_headers"

    echo -e $all_http_request
}


function get_http_body {

    # strip off the HTTP response headers from standard-input

    sed '1,/^'$'\r''$/d'
}


function docker_transport_cmd {

    # see which command to connect to the Docker API, either openssl or nc
    # and run it, taking the standard-input as std-in to the chosen command

    if [[ "$DOCKER_TLS_VERIFY" != "0" ]]; then
        openssl s_client -host ${V_DOCKER_IP?} -port ${V_DOCKER_PORT?} \
                         -no_ssl2 -quiet \
                         -cert ${DOCKER_CERT_PATH?}/cert.pem \
                         -key ${DOCKER_CERT_PATH?}/key.pem \
                         -CAfile ${DOCKER_CERT_PATH?}/ca.pem

    else
        nc  ${V_DOCKER_IP?}  ${V_DOCKER_PORT?}
        # Using socat instead, if available
        # socat - tcp:$V_DOCKER_IP:$V_DOCKER_PORT
    fi  | \
          get_http_body
}


function json_fmt {
    python -m json.tool
}


if [ -z ${V_DOCKER_IP+x} ]; then
    echo "Variable V_DOCKER_IP is unset. Please set it with the IP address" \
         " of the Docker API server before using these functions" >&2
fi

if [ -z ${V_DOCKER_PORT+x} ]; then
    echo "Variable V_DOCKER_PORT is unset. Please set it with the TCP port" \
         " of the Docker API server before using these functions" >&2
fi

