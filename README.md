# Docker_API

An example of the Docker API based on:

       http://docs.docker.com/reference/api/docker_remote_api_v1.19/

e.g., by calling the API in low-level through `openssl s_client` directly.

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

