#!/bin/bash

set -e

# load the library
. bashopts.sh # For more information check it out https://gitlab.mbedsys.org/mbedsys/bashopts

# Enable backtrace display on error
#trap 'bashopts_exit_handle' ERR

# Initialize the library
bashopts_setup -n $0 -d "Stack manager" -u "$0 [options and commands] [-- [extra args]]" -x

# Declare the options
bashopts_declare -n ACTION -l action -o a -d "Action" -t enum -e 'deploy' -e 'remove' -r
bashopts_declare -n ENV -l environment -o e -d "Environemnt" -t enum -e 'prod' -e 'dev' -r

# Parse arguments
bashopts_parse_args "$@"

# Process options
bashopts_process_opts

if [ $ACTION = "deploy" ]; then 

    echo "Deploying $ENV environment stack"

    echo "Checking volumes"    
    PORTAINER_VOLUME_COUNT=$(docker volume ls | grep -c portainer || true)

    if [ "$PORTAINER_VOLUME_COUNT" -eq 0 ]; then
        echo "Creating postgresql volume"
        docker volume create --name=portainer
    fi

    export COMPOSE_CONVERT_WINDOWS_PATHS=1
    docker stack deploy --compose-file docker-compose.base.yaml --compose-file docker-compose.${ENV}.yaml conradodev
elif [ $ACTION = "remove" ]; then
    docker stack rm conradodev
fi