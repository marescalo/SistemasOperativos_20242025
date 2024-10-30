#!/bin/bash

usage(){
    echo "usage: infosession.sh [-h] [-z] [-u user]"
}

encabezado="SID PGID PID USER TTY %MEM CMD"
procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
flag_z=0
flag_u=0
flag_d=0

tabla(){

  echo $encabezado
  if [ "$flag_u" == 1 ]; then
    procesos="$procesos | grep '$usuario'"
  fi
  if [ $flag_z == 0 ]; then
    procesos="$procesos | grep --invert-match ^0"
  fi
  if [ $flag_d == 1 ]; then
    procesos="$($procesos )"
  fi

}


echo "muestra los procesos..."

# si no se mete ninguna opcion
if [ "$1" == "" ]; then
  echo "SID PGID PID USER TTY %MEM CMD"
  echo -e "$(ps -u $USER -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print $1,$2,$3,$4,$5,$6,$7}' | grep --invert-match ^0)"
  exit
fi

# cuando se le meta una opcion
while [ "$1" != "" ]; do
    case $1 in
        -u | -user)
            flag_u=1
            usuario=$2 
            if [ $usuario == "" ]; then
                echo "Se ha introducido una opcion de usuario no valida"
                exit 1
            fi
            shift
            ;;
        -z)
            flag_z=1
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        -d)
            flag_d=1
            ;;
        *) 
            
            exit 0
            ;;
    esac
    shift
done

tabla
eval "$procesos"