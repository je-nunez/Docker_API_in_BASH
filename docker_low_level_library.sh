#!/usr/bin/env bash

#
# Library of utility functions, which resemble the `docker` command but uses
# `openssl s_client` or `netcat` to communicate with the Docker daemon.
#
# This use of a low-level access through `openssl s_client`, etc, avoids
# issues in Docker like the version mismatch between Docker client and server:
#
#     Error response from daemon: client and server don't have same version
#                                 (client : 1.nnn, server: 1.mmm)
#
#  where sometimes it is not easy or prompt to upgrade.



# Functions with start with the "_" preffix are intended for internal use
# although they can be called directly too

# function _Docker_API_raw_string
# gets the HTTP request command and headers to send to the Docker daemon

function _Docker_API_raw_string {

    # prints to standard-output the Docker API raw string we need to use

    local http_method=${1?HTTP request method expected as first parameter}
    local http_request=${2?HTTP request string expected as second parameter}


    local other_http_req_headers="Host: ${V_DOCKER_IP?}:${V_DOCKER_PORT?}\r\nUser-Agent: Command-line/0.0.1\r\nAccept: */*\r\n\r\n"

    local all_http_request="$http_method $http_request HTTP/1.0\r\n$other_http_req_headers"

    echo -e $all_http_request

}

# function _get_http_body
# gets only the HTTP response body, discarding the HTTP response header

function _get_http_body {

    # strip off the HTTP response headers from standard-input

    sed '1,/^'$'\r''$/d'
}

# function _docker_transport_cmd
# sends the standard-input to the Docker daemon either through
# `openssl s_client` or with `netcat` (`socat` is also another
# possibility).

function _docker_transport_cmd {

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

# function _json_fmt
# formats the JSON it reads from standard-input

function _json_fmt {

    python -m json.tool

}

# function _check_environment_vars
# checks if some required environment variables are set before
# running the exported functions in this library. Also the
# initialization code of this library warns if any of the
# required environment variables are not set.

function _check_environment_vars {

     if [ -z ${DOCKER_TLS_VERIFY+x} ]; then
        echo "Variable DOCKER_TLS_VERIFY is unset. Please set it with " \
         "whether to verify TLS with the Docker daemon." >&2
        return 1
     fi

     if [ "${DOCKER_TLS_VERIFY}" != "0" -a -z ${DOCKER_CERT_PATH+x} ]; then
        echo "Variable DOCKER_CERT_PATH is unset. Please set it with " \
         "the path of the certificates to connect to the Docker daemon." >&2
        return 2
     fi

     if [ -z ${V_DOCKER_IP+x} ]; then
        echo "Variable V_DOCKER_IP is unset. Please set it with the IP " \
         "address of the Docker API server before using these functions" >&2
        return 3
     fi

     if [ -z ${V_DOCKER_PORT+x} ]; then
        echo "Variable V_DOCKER_PORT is unset. Please set it with the TCP " \
         "port of the Docker API server before using these functions" >&2
        return 4
     fi
     return 0

}

#
# Exported functions of this Docker API library which glue the internal calls
# to the other functions in this library
#

function docker_ping {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     _Docker_API_raw_string "GET"  "/_ping" | _docker_transport_cmd

}

function docker_daemon_info {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     _Docker_API_raw_string "GET"  "/info" | _docker_transport_cmd | _json_fmt

}

function docker_info {
    docker_daemon_info $@
    return $?
}



function docker_list_images {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     _Docker_API_raw_string "GET"  "/images/json" | _docker_transport_cmd | \
                            _json_fmt

}

function docker_images {
     docker_list_images $@
     return $?
}



function docker_list_containers {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     _Docker_API_raw_string "GET"  "/containers/json?all=1" | \
                         _docker_transport_cmd | _json_fmt

}

function docker_ps {
     docker_list_containers $@
     return $?
}



function docker_inspect_container {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

     _Docker_API_raw_string "GET"  "/containers/${container_id}/json" | \
                         _docker_transport_cmd | _json_fmt

}

function docker_inspect {
     docker_inspect_container $@
     return $?
}



function docker_logs_container {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

     _Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/logs?stderr=1&stdout=1&timestamps=1" | \
                         _docker_transport_cmd

}

function docker_logs {
     docker_logs_container $@
     return $?
}



function docker_top_processes {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

     _Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/top?ps_args=auxwww" | \
                         _docker_transport_cmd | _json_fmt

}

function docker_top {
     docker_top_processes $@
     return $@
}



function docker_diff_changes_container {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

     _Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/changes" | \
                         _docker_transport_cmd | _json_fmt

}

function docker_diff {
     docker_diff_changes_container $@
     return $?
}




function docker_save_tar_ball {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

      _Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/export" | \
                         _docker_transport_cmd

}

function docker_save {
      docker_save_tar_ball $@
}




function docker_kernel_stats {

     _check_environment_vars
     local check_ok=$?
     [[ "$check_ok" -ne 0 ]] && echo "Aborting" >&2 && return "$check_ok"

     local container_id="${1?Docker container ID necessary as first argument}"

      # (it is a continuous stream, hence 'head -n 1' below)

      _Docker_API_raw_string "GET"  \
                      "/containers/${container_id}/stats?stream=0" | \
                         _docker_transport_cmd | head -n 1 | _json_fmt

}


#
# Initialization code of the library
#

# warn if the necessary environment variables are not yet set

_check_environment_vars

