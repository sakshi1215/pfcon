#!/bin/bash

G_SYNOPSIS="

 NAME

	docker-deploy.sh

 SYNOPSIS

	docker-deploy.sh [up|down]

 ARGS

	[up|down]
	Denotes whether to fire up or tear down the production set of services.

 DESCRIPTION

	docker-deploy.sh script will depending on the argument deploy the pfcon set
    of services in production or tear down the system.

"

if [[ "$#" -eq 0 ]] || [[ "$#" -gt 1 ]]; then
    echo "$G_SYNOPSIS"
    exit 1
fi

source ./decorate.sh

declare -i STEP=0


if [[ "$1" == 'up' ]]; then

    title -d 1 "Checking required FS directory tree for remote services in host filesystem..."
    mkdir -p FS/remote
    chmod -R 777 FS
    export STOREBASE=$(pwd)/FS/remote
    windowBottom

    title -d 1 "Starting pfcon_stack production deployment on swarm using " " ./docker-compose.yml"
    declare -a A_CONTAINER=(
    "fnndsc/pfcon"
    "fnndsc/pman"
    )
    echo "Pulling latest version of all service containers..."
    for CONTAINER in ${A_CONTAINER[@]} ; do
        echo ""
        CMD="docker pull $CONTAINER"
        echo -e "\t\t\t${White}$CMD${NC}"
        echo $sep
        echo $CMD | sh
        echo $sep
    done
    echo "docker stack deploy -c docker-compose.yml pfcon_stack"
    docker stack deploy -c docker-compose.yml pfcon_stack
    windowBottom
fi

if [[ "$1" == 'down' ]]; then

    title -d 1 "Destroying pfcon_stack production deployment on swarm" "from ./docker-compose.yml"
    docker stack rm pfcon_stack >& dc.out >/dev/null
    cat dc.out                                                              | ./boxes.sh
    echo "Removing ./FS tree"                                               | ./boxes.sh
    rm -fr ./FS
    windowBottom
fi
