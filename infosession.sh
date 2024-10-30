#!/bin/bash

usage(){
    echo "usage: infosession.sh [-h] [-z] [-u user]"
}

procesos="$(ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user  | awk '{print $1, $2, $3, $4, $5, $6, $7}')"
usuario=$USER
opcion_z=0

# si no se mete ninguna opcion

if [ "$1" == "" ]; then

  echo -e "$(ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print $1,$2,$3,$4,$5,$6,$7}' | grep --invert-match 0.0)"

fi

# cuando se le meta una opcion

while [ "$1" != "" ]; do
    case $1 in
        -u | -user)
            shift
            usuario=$2
            ;;
        -z)
            opcion_z=1
            ;;
        -h | --help)
            usage
            exit
            ;;
        *) 
            echo $procesos
            exit 0
            ;;
    esac
    shift
done

echo "muestra los procesos..."