#!/bin/bash

# Variables de entorno
encabezado_tabla="SID PGID PID USER TTY %MEM CMD"
encabezado_tabla_sesiones="SID NUM_GRUPOS LIDER_PID LIDER_USER LIDER_TTY LIDER_CMD"
procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
flag_z=0
flag_u=0
flag_d=0
flag_t=0
flag_e=0
flag_r=0
flag_sm=0
user_list=()

#MODIFICACION
total_grupos=0
total_sesiones=0

# Muestra el --help
usage(){
    echo "usage: infosession.sh [-h] [-z] [-u user] [-d dir ] [-t] [-e]"
    echo "Opciones:"
    echo "  -h          Muestra esta ayuda"
    echo "  -z          Incluye procesos con SID 0."
    echo "  -u [user1, ...] Muestra procesos de los usuarios especificados."
    echo "  -d [dir]      Muestra solo procesos que tengan archivos abiertos en el directorio especificado."
    echo "  -t          Muestra solo procesos con terminal controladora asociada."
    echo "  -e          Muestra la tabla de procesos detallada."
}

# Imprime la tabla de procesos detallada
tabla(){

  if [ $flag_sm == 1 ]; then
    procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=%mem | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
  else
    procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
  fi
  
  # Filtro por usuario si se usa -u
  if [ "$flag_u" == 1 ]; then
      if [[ ${#user_list[@]} -gt 0 ]]; then
        user_filter=$(IFS="|"; echo "${user_list[*]}")
        procesos="$procesos | awk '\$4 ~ /^($user_filter)$/ {print}'"
      fi
  fi
  # Opción -z
  if [ $flag_z == 0 ]; then
    procesos="$procesos | grep --invert-match ^0"
  fi
  # Opción -d
  if [ $flag_d == 1 ]; then
    if [[ -n "$pid_rutadir" ]];then
      pid_filter=$(echo "$pid_rutadir" | tr '\n' '|')
      pid_filter="${pid_filter%|}"
      procesos="$procesos | awk '\$3 ~ /^($pid_filter)$/'"
    fi
  fi
  # Opción -t
  if [ $flag_t == 1 ]; then
    procesos="$procesos | grep --invert-match ?"
  fi

  if [ $flag_r == 1 ]; then
    procesos="$procesos | tac"
  fi

  eval "$procesos"
}

# Imprime la tabla de sesiones
tabla_sesiones(){
  
  if [ $flag_sm == 1 ]; then
    procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=%mem | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
  else
    procesos="ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user | awk '{print \$1,\$2,\$3,\$4,\$5,\$6,\$7}'"
  fi

  # Filtro para usuario si se usa -u
  if [ "$flag_u" == 1 ]; then
      if [[ ${#user_list[@]} -gt 0 ]]; then
        user_filter=$(IFS="|"; echo "${user_list[*]}")
        procesos="$procesos | awk '\$4 ~ /^($user_filter)$/ {print}'"
      fi
  else
      # Excluir "root" si no se especifica -u root
      procesos="$procesos | awk '\$4 != \"root\" {print}'"
  fi
  
  # Filtro para la opción -z (excluir SID 0 si no está activada)
  if [ $flag_z == 0 ]; then
    procesos="$procesos | grep --invert-match ^0"
  fi

  # Filtro para la opción -d (directorios específicos)
  if [ $flag_d == 1 ]; then
    if [[ -n "$pid_rutadir" ]];then
      pid_filter=$(echo "$pid_rutadir" | tr '\n' '|')
      pid_filter="${pid_filter%|}"
      procesos="$procesos | awk '\$3 ~ /^($pid_filter)$/'"
    else
      procesos=""
    fi
  fi

  # Filtro para la opción -t (terminal controladora)
  if [ $flag_t == 1 ]; then
    procesos="$procesos | grep --invert-match  "
  fi

  if [ $flag_r == 1 ]; then
    procesos="$procesos | tac"
  fi

  # Procesamiento de la tabla de sesiones
  eval "$procesos" | sort -k1,1 -k2,2 | awk '
  BEGIN {
    # Inicializa los arrays asociativos
    delete sesiones
    delete lider_user
    delete lider_tty
    delete lider_cmd
    delete num_grupos
    delete grupos
  }
  {
    sid = $1  # Asigna SID
    pgid = $2  # Asigna PGID
    pid = $3  # Asigna PID
    user = $4  # Asigna usuario
    tty = $5  # Asigna terminal
    cmd = $7  # Asigna comando

    # Si es la primera vez que encontramos el SID, guardamos datos de líder
    if (!(sid in sesiones)) {
      sesiones[sid] = pid
      lider_user[sid] = user
      lider_tty[sid] = tty
      lider_cmd[sid] = cmd
      num_grupos[sid] = 0
    }
    
    # Contar grupos únicos por sesión usando clave compuesta "sid-pgid"
    key = sid "-" pgid  # Genera una clave única combinada de SID y PGID
    if (!(key in grupos)) {  # Verifica si la clave combinada ya existe
      grupos[key] = 1  # Marca la clave como registrada
      num_grupos[sid]++
    }
  }
  END {
    # Imprimir datos por sesión
    for (s in sesiones) {
      printf "%s %d %s %s %s %s\n", s, num_grupos[s], sesiones[s], lider_user[s], lider_tty[s], lider_cmd[s]
    }
  }' 
}


# Procesamiento de opciones
while [ "$1" != "" ]; do
    case $1 in
        -u | -user)
            flag_u=1
            shift
            while [[ "$1" != "" && "$1" != -* ]]; do
              user_list+=("$1")
              shift
            done
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
            pid_rutadir=$(lsof +d $2 -t)
            shift
            ;;
        -t) 
            flag_t=1 
            ;;
        -e) 
            flag_e=1 
            ;;
        -sm)
            flag_sm=1
            ;;
          
        -r)
            flag_r=1
            ;;
        *) 
            echo "Opción no válida: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

# Mostrar tabla de procesos detallada o tabla de sesiones según la opción -e
if [ $flag_e == 1 ]; then
    echo $encabezado_tabla
    tabla
else
    echo $encabezado_tabla_sesiones  # Imprime el encabezado de la tabla de sesiones
    tabla_sesiones
fi
