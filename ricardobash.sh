#!/bin/bash

# --- FUNCIONES --- #

# Calcula el factorial de un número dado.
# Si no se proporciona un número, muestra un mensaje de error.
factorial(){
  if [ -z $1 ]; then
    echo "Debe introducir un número."
    exit 1
  fi

  fact=1
  for ((i=1; i<=$1; i++)); do
    fact=$((fact * i))
  done

  echo "El factorial de $1 es: $fact"
}

# Verifica si un año es bisiesto.
# Un año es bisiesto si es divisible por 4 y no por 100, o si es divisible por 400.
bisiesto(){
  if [ -z $1 ]; then
    echo "Debe introducir un año."
    exit 1
  fi

  if (( ($1 % 4 == 0 && $1 % 100 != 0) || ($1 % 400 == 0) )); then
    echo "El año $1 es bisiesto."
  else
    echo "El año $1 no es bisiesto."
  fi
}

# Configura la red en un sistema usando netplan.
# Crea una copia de seguridad del archivo de configuración y aplica la nueva configuración.
configurared(){
  netplan="/etc/netplan/50-cloud-init.yaml"
  backup="/etc/netplan/50-cloud-init.yaml"

  if [ -f $netplan ]; then
    echo "Respaldando configuración actual..."
    sudo cp $netplan $backup
  fi

  cat << EOF | sudo tee $netplan
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - $1/$2
      routes:
        - to: default
          via: $3
      nameservers:
        addresses: [$4]
EOF

  echo "Aplicando configuración..."
  netplan apply
  ip a  # Muestra la nueva configuración de red.
}

# Juego en el que el usuario debe adivinar un número aleatorio entre 1 y 100.
# Informa si el número ingresado es mayor o menor al objetivo.
adivina(){
  num=$((RANDOM % 100 + 1))
  try=0
  numusu=0

  while (( numusu != num )); do
    read -p "Introduzca un número: " numusu
    ((try++))

    if (( numusu == num )); then
      echo "¡Enhorabuena! Ha adivinado el número $num en $try intentos."
      break
    elif (( numusu < num )); then
      echo "Pruebe con un número mayor."
    else
      echo "Pruebe con un número menor."
    fi
  done
}

# Determina la etapa de la vida según la edad introducida.
edad(){
  case $1 in
    [0-2]) echo "Está en la niñez." ;;
    [3-9]|10) echo "Está en la infancia." ;;
    1[1-7]) echo "Está en la adolescencia." ;;
    1[8-9]|[2-3][0-9]) echo "Está en la juventud." ;;
    4[0-9]|5[0-9]|6[0-4]) echo "Está en la madurez." ;;
    6[5-9]|[7-9][0-9]|[1-9][0-9][0-9]*) echo "Está en la vejez." ;;
    *) echo "Por favor, introduzca una edad válida." ;;
  esac
}

# Muestra información sobre un archivo, incluyendo tamaño, tipo, inodo y punto de montaje.
fichero(){
  if [ -z  $1 ]; then
    echo "Debe introducir un parámetro."
    exit 1
  fi

  echo "Información del fichero: $1"
  echo "--------------------------------"
  echo "Tamaño: $(stat --format="%s" "$1") bytes"
  echo "Tipo: $(stat --format="%F" "$1")"
  echo "Inodo: $(stat --format="%i" "$1")"
  echo "Punto de montaje: $(df --output=target "$1" | tail -n 1)"
}

# Busca un archivo en el sistema y cuenta cuántas vocales contiene.
buscar(){
  ruta=$(find / -type f -name "$1" 2>/dev/null)

  if [ -z "$ruta" ]; then
    echo "Error: El fichero '$1' no existe en el sistema."
    exit 1
  else
    echo "El fichero se encuentra en: $ruta"
    vocales=$(grep -o -i '[aeiou]' "$ruta" | wc -l)
    echo "El fichero contiene $vocales vocales."
  fi
}

# Cuenta la cantidad de archivos en un directorio especificado.
contar(){
  read -p "Introduzca el directorio donde contar los ficheros: " directorio

  if [ ! -d "$directorio" ]; then
    echo "Error: El directorio '$directorio' no existe."
    exit 1
  fi

  num_ficheros=$(find "$directorio" -type f | wc -l)
  echo "El directorio '$directorio' contiene $num_ficheros ficheros."
}

# Verifica si el usuario tiene permisos administrativos en el sistema.
privilegios(){
  usu=$(whoami)

  if sudo -n true; then
    echo "El usuario $usu tiene permisos administrativos."
  else
    echo "El usuario $usu no tiene permisos administrativos."
  fi
}

# Muestra los permisos de un archivo en formato octal.
permisosoctal(){
  if [ -z $1 ]; then
    echo "Debe introducir un parámetro."
    exit 1
  fi

  echo "Permisos octales de $1: $(stat -c "%a" "$1")"
}

# Convierte un número entre 1 y 200 a números romanos.
romano(){
  if [[ $1 -lt 1 || $1 -gt 200 ]]; then
    echo "El número debe estar comprendido entre 1 y 200."
    exit 1
  fi

  simbolos=(C XC L XL X IX V IV I)
  valores=(100 90 50 40 10 9 5 4 1)

  numero=$1
  resultado=""

  for i in "${!valores[@]}"; do
    while (( numero >= valores[i] )); do
      resultado+=${simbolos[i]}
      (( numero -= valores[i] ))
    done
  done

  echo "El número $1 en romano es: $resultado"
}

# Crea un usuario por cada archivo en /mnt/usuarios y genera sus directorios personales.
automatizar(){
  DIR_USUARIOS="/mnt/usuarios"

  if [ -z "$(ls -A $DIR_USUARIOS 2>/dev/null)" ]; then
    echo "El directorio $DIR_USUARIOS está vacío. No hay usuarios que crear."
    exit 0
  fi

  for archivo in "$DIR_USUARIOS"/*; do
    usuario=$(basename "$archivo")

    if id "$usuario" &>/dev/null; then
        echo "El usuario $usuario ya existe. Omitiendo..."
    else
        useradd -m "$usuario"
        echo "Usuario $usuario creado."
    fi

    while IFS= read -r carpeta; do
        if [ -n "$carpeta" ]; then
            mkdir -p "/home/$usuario/$carpeta"
            echo "Carpeta /home/$usuario/$carpeta creada."
        fi
    done < "$archivo"

    rm -f "$archivo"
    echo "Archivo $archivo eliminado después de procesarlo."
  done

  echo "Proceso de automatización completado."
}

# Crea un archivo con el nombre y tamaño especificados en KB.
# Si no se proporciona un nombre, se usa "fichero_vacio".
# Si no se especifica un tamaño, se usa 1024 KB por defecto.
crear(){
  if [[ -z $1 ]] || [[ "$1" =~ ^[0-9]+$ ]]; then
    nombre="fichero_vacio"
    tamano=${1:-1024}
  else
    nombre="${1:-fichero_vacio}"
    tamano="${2:-1024}"
  fi

  fallocate -l "${tamano}K" "$nombre"
  echo "Fichero '$nombre' creado con un tamaño de $tamano KB."
}


# Igual que "crear", pero evita sobrescribir archivos existentes.
# Si el archivo ya existe, añade un número (1-9) al final del nombre.
crear2(){
  if [[ -z $1 ]] || [[ "$1" =~ ^[0-9]+$ ]]; then
    nombre="fichero_vacio"
    tamano="${1:-1024}"
  else
    nombre="$1"
    tamano="${2:-1024}"
  fi

  if [[ -e "$nombre" ]]; then
    for i in {1..9}; do
      nuevo_nombre="${nombre}${i}"
      if [[ ! -e "$nuevo_nombre" ]]; then
        nombre="$nuevo_nombre"
        break
      fi
    done
  fi

  if [[ -e "$nombre" ]]; then
    echo "Error: Existen archivos con nombres ${nombre}{1..9}. No se creará el archivo."
    return 1
  fi

  fallocate -l "${tamano}K" "$nombre"
  echo "Fichero '$nombre' creado con un tamaño de $tamano KB."
}

# Reemplaza las vocales en una palabra por números:
# a → 1, e → 2, i → 3, o → 4, u → 5.
reescribir(){
  if [[ -z $1 ]]; then
    echo "Debe introducir una palabra."
    return 1
  fi

  palabra_modificada="${1//a/1}"
  palabra_modificada="${palabra_modificada//e/2}"
  palabra_modificada="${palabra_modificada//i/3}"
  palabra_modificada="${palabra_modificada//o/4}"
  palabra_modificada="${palabra_modificada//u/5}"

  echo "Palabra modificada: $palabra_modificada"
}

# Cuenta los usuarios del sistema con directorio en /home.
# Permite seleccionar un usuario y realiza una copia de seguridad de su home.
contusu(){
    usuarios=( $(ls /home) )
    num_usuarios=${#usuarios[@]}

    if [[ $num_usuarios -eq 0 ]]; then
        echo "No hay usuarios en el sistema."
        return 1
    fi

    echo "Usuarios reales en el sistema:"
    for i in "${!usuarios[@]}"; do
        echo "$((i+1))) ${usuarios[$i]}"
    done

    read -p "Seleccione un usuario por número: " seleccion

    if (( seleccion < 1 || seleccion > num_usuarios )); then
        echo "Selección inválida."
        return 1
    fi

    usuario_seleccionado="${usuarios[$((seleccion-1))]}"
    ruta_backup="/home/copiaseguridad/${usuario_seleccionado}_$(date +%Y-%m-%d)"

    mkdir -p "$ruta_backup"
    cp -r "/home/$usuario_seleccionado"/* "$ruta_backup"

    echo "Copia de seguridad en: $ruta_backup"
}

# Solicita el número de alumnos y sus notas.
# Cuenta cuántos aprobaron, cuántos suspendieron y calcula la nota media.
alumnos(){
  if [[ $1 -le 0 ]]; then
    echo "Debe introducir un número válido."
    return 1
  fi

  aprobados=0
  suspensos=0
  suma_notas=0

  for (( i=1; i<=$1; i++ )); do
    read -p "Introduce la nota del alumno $i: " nota
    suma_notas=$(echo "$suma_notas + $nota" | bc -l)

    if (( $(echo "$nota >= 5" | bc -l) )); then
      ((aprobados++))
    else
      ((suspensos++))
    fi
  done

  media=$(echo "scale=2; $suma_notas / $1" | bc -l)

  echo "Aprobados: $aprobados"
  echo "Suspensos: $suspensos"
  echo "Nota media: $media"
}

# Renombra archivos en el directorio actual, reemplazando espacios con guiones bajos (_).
quita_blancos(){
    for archivo in *; do
        if [[ "$archivo" =~ \  ]]; then
            nuevo_nombre="${archivo// /_}"
            mv "$archivo" "$nuevo_nombre"
            echo "Renombrado: '$archivo' → '$nuevo_nombre'"
        fi
    done
}

# Imprime varias líneas de un carácter especificado con la longitud deseada.
# Requiere tres parámetros: carácter, longitud de la línea (1-60) y número de líneas (1-10).
lineas(){
 if [[ $# -ne 3 ]]; then
        echo "Debe introducir tres parámetros."
        return 1
    fi

    caracter="$1"
    longitud="$2"
    num_lineas="$3"

    if (( longitud < 1 || longitud > 60 )) || (( num_lineas < 1 || num_lineas > 10 )); then
        echo "Error: Parámetros fuera de rango."
        return 1
    fi

    for (( i=1; i<=num_lineas; i++ )); do
        printf "%-${longitud}s\n" | tr ' ' "$caracter"
    done
}

# Cuenta cuántos archivos hay de cada tipo en un directorio y sus subdirectorios.
# Se pasa como argumento el directorio y las extensiones a analizar.
analizar(){
    if [[ $# -lt 2 ]]; then
        echo "Debe introducir un directorio y al menos una extensión."
        return 1
    fi

    directorio="$1"
    shift

    if [[ ! -d "$directorio" ]]; then
        echo "Error: El directorio no existe."
        return 1
    fi

    echo "Análisis de: $directorio"
    for ext in "$@"; do
        cantidad=$(find "$directorio" -type f -name "*.$ext" | wc -l)
        echo "Archivos .$ext: $cantidad"
    done
}

#Variable de número y menú
	clear
	echo "---------- Menú ----------"
	echo "1. Factorial."
	echo "2. Bisiesto."
	echo "3. ConfiguraRed."
	echo "4. Adivina."
	echo "5. Edad."
	echo "6. Fichero."
	echo "7. Buscar."
	echo "8. Contar."
	echo "9. Privilegios."
	echo "10. PermisosOctal."
	echo "11. Romano."
	echo "12. Automatizar."
	echo "13. Crear."
	echo "14. Crear 2."
	echo "15. Reescribir."
	echo "16. ContUsu."
	echo "17. Alumnos."
	echo "18. Quita_Blancos."
	echo "19. Líneas."
	echo "20. Analizar."
	echo "0. Salir."
	echo "---------------------------"
	read -p "Seleccione una opción: " op
	echo ""
	case $op in
	   0)clear
	    echo "Saliendo del menú..."
	    sleep 1
	   ;;

	   1)clear
	    read -p "Introduzca un número: " num
	    factorial "$num"
	   ;;

	   2)clear
             read -p "Introduzca un año: " anio
             bisiesto "$anio"
	   ;;

	   3)clear
             read -p "Introduzca la nueva dirección ip: " ip
             read -p "Introduzca la máscara de red: " mr
             read -p "Introduzca la puerta de enlace: " gw
             read -p "Introduzca el servidor DNS: " dns
             configurared $ip $mr $gw $dns
	   ;;

	   4)clear
	     echo "Ha elegido jugar."
	     adivina
	   ;;

	   5)clear
	     read -p "Introduzca una edad: " edad
             edad $edad
	   ;;

	   6)clear
	     read -p "Introduzca el nombre del fichero a buscar: " fichero
             fichero $fichero
	   ;;

	   7)clear
             read -p "Introduzca el nombre del fichero a contar las vocales: " fichvoc
	     buscar $fichvoc
	   ;;

	   8)clear
             echo "Ha elegido contar los fichero de un directorio."
             contar
	   ;;

	   9)clear
             privilegios
	   ;;

	   10)clear
              read -p "Introduzca la ruta de un archivo: " octal
              permisosoctal $octal
	   ;;

	   11)clear
              read -p "Introduzca un número comprendido entre 0 y 200: " num
              romano $num
	   ;;

	   12)clear
              echo "Ha elegido automatizar."
              automatizar
	   ;;

	   13)clear
              read -p "Introduzca el nombre del archivo: " nom
              read -p "Introduzca el tamaño del archivo en KB: " tam
              crear $nom $tam
	   ;;

	   14)clear
              read -p "Introduzca el nombre del archivo: " nom
              read -p "Introduzca el tamaño del archivo en KB: " tam
              crear2 $nom $tam
	   ;;

	   15)clear
              read -p "Introduzca la palabra a reescribir: " pal
              reescribir $pal
	   ;;

	   16)clear
              echo "Ha elegido contar los usuarios del sistema."
              contusu
	   ;;

	   17)clear
              read -p "Introduzca el número de alumnos: " alum
              alumnos $alum
	   ;;

	   18)clear
              echo "Ha elegido quitar blancos."
              quita_blancos
	   ;;

	   19)clear
             read -p "Introduzca un carácter: " carac
             read -p "Introduzca la longitud de la línea: " long
             read -p "Introduzca el número de líneas: " numli
             lineas $carac $long $numli
	   ;;

	   20)clear
             read -p "Introduzca un directorio: " dir
             read -p "Introduzca una extensión: " ext
             analizar $dir $ext
	   ;;

	   *)clear
	     echo "Opción no válida."
	     sleep 2
	   ;;
	esac
