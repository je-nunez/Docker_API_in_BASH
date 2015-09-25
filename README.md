# Docker_API

An example of the Docker API based on:

       http://docs.docker.com/reference/api/docker_remote_api_v1.19/

e.g., by calling the API in low-level through `openssl s_client` directly.

The normal way to connect to docker servers is through the `docker` client. The
inspiration for this raw connection in BASH was when a docker client (which
possessed network connectivity to the docker servers), couldn't connect to them
because of a window-in-time small version mismatch between the docker protocol,
and the docker client couldn't be updated in this same window of time and
`openssl` was the only thing at hand (lesson learned: upgrade clients first):

      docker ps
          Error response from daemon: client and server don't have same version (client: <docker-client-version>, server: <docker-server-version>)

Since docker version 1.7.1-RC1, it merely gives a warning, before this version it had been:

        if version.GreaterThan(api.APIVERSION) {
                http.Error(w, fmt.Errorf("client and server don't have same version (client API version: %s, server API version: %s)", version, api.APIVERSION).Error(), http.StatusBadRequest)
                return
        }

So use with care a raw connection, and preferably, upgrade to a `docker` version 1.7.1 or
higher.

# WIP

This project is a *work in progress*. The implementation is *incomplete* and subject to change. The documentation can be inaccurate.

# Files

Files:

      docker_low_level_library.sh
      
           This is the library of BASH functions, using either 'netcat' or
           'openssl s_client', which allows to connect directly to a remote
           Docker API from the BASH shell.
      
      
      examples_of_the_docker_low_level_library_in_BASH.sh:
      
           Some examples of some Docker API commands using the library
           'docker_low_level_library.sh' of BASH functions (above).

