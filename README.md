# Docker_API

An example of the Docker API based on:

       http://docs.docker.com/reference/api/docker_remote_api_v1.19/

e.g., by calling the API in low-level through `openssl s_client` directly.

Files:

      docker_low_level_library.sh
      
           This is the library of BASH functions, using either 'netcat' or
           'openssl s_client', which allows to connect directly to a remote
           Docker API from the BASH shell.
      
      
      docker_API_commands_over_openssl_s_client_cheat_sheet.sh:
      
           A cheat-sheet with some Docker API commands using the library
           'docker_low_level_library.sh' of BASH functions (above).

