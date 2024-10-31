#!/bin/bash

#varibales de entorno
encabezado="SID PGID PID USER TTY %MEM CMD"
procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
flag_z=0
flag_u=0
flag_d=0

#muestra el --help
usage(){
    echo "usage: infosession.sh [-h] [-z] [-u user] [-d dir ]"
}

#imprimimos la tabla
tabla(){
  echo $encabezado
  #opcion -u
  if [ "$flag_u" == 1 ]; then
    procesos="$procesos | grep '$usuario'"
  fi
  #opcion -z
  if [ $flag_z == 0 ]; then
    procesos="$procesos | grep --invert-match ^0"
  fi
  #opcion -d
  if [ $flag_d == 1 ]; then
    procesos="$procesos | lsof +d ruta_dir "
  fi
}

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
            ruta_dir=$2
            if [ $ruta_dir == "" ]; then
                echo "Se ha introducido una opcion de directorio no valida"
                exit 1
            fi
            ;;
        *) 
            echo "la opcion o una de las opciones introducidas no es parte de las opciones aceptadas por el programa"
            usage
            exit 0
            ;;
    esac
    shift
done

echo "muestra los procesos: "
tabla
eval "$procesos"