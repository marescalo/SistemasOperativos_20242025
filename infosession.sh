#!/bin/bash

usage(){
    echo "usage: infosession.sh [-u user] [-z] [-h]"
}

usuario=
opcion_z=0

while [ "$1" != "" ]; do
    case $1 in
        -u | --user )
            shift
            usuario=$1
            ;;
        -z )
            opcion_z=1
            ;;
        -h | --help ) 
            usage
            exit
            ;;
        * ) 
            usage
            exit 1
    esac
    shift
done
echo "muestra los procesos..."