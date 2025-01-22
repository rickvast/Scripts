#!/bin/bash

#--- FUNCIONES ---#

#Factorial
factorial(){
  if [ -z "$1" ]; then
    echo "Uso del script: $0 <NÚMERO>"
    exit 1
  fi

   fact=1
     for((i=1;i<=$1;i++))
       do
	 fact=$((fact * i))
       done
   echo "El factorial de $1 es: $fact"
}


#Bisiesto
bisiesto(){
  if [ -z "$1" ]; then
    echo "Uso del script: $0 <AÑO>"
    exit 1
  fi

  if (( ($1 % 4 == 0 && $1 % 100 != 0) || ($1 % 400 == 0) )); then
    echo "El año $1 es bisiesto."
  else
    echo "El año $1 no es bisiesto."
  fi
}


#ConfiguraRed
configurared(){
  if [ "$#" -ne 5 ]; then
    echo "Uso del script: $0 <INTERFAZ> <IP> <MÁSCARA> <GATEWAY> <DNS>"
    exit 1
  fi

  ip addr flush dev $1
  ip addr add $2/$3 dev $1
  ip route add default via $4 dev $1
  echo "nameserver $5" | tee /etc/resolv.conf > /dev/null
}


#Adivina
adivina(){
num=$((RANDOM % 100 + 1))
try=0
numusu=0

while (( numusu != num)); do
  read -p "Introduzca un número: " numusu

  if ! [[ "$numusu" =~ ^[0-9]+$ ]]; then
    echo "Por favor, introduzca un número válido."
    continue
  fi

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


#Edad
edad(){
read -p "Introduzca su edad: " edad

case $edad in
  [0-2]) echo "Está en la niñez." ;;
  [3-9]|10) echo "Está en la infancia." ;;
  1[1-7]) echo "Está en la adolescencia." ;;
  1[8-9]|[2-3][0-9]) echo "Está en la juventud." ;;
  4[0-9]|5[0-9]|6[0-4]) echo "Está en la madurez." ;;
  6[5-9]|[7-9][0-9]|[1-9][0-9][0-9]*) echo "Está en la vejez." ;;
  *) echo "Por favor, introduzca una edad válida." ;;
esac
}


#Información Fichero
fichero(){
  if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <NOMBRE_FICHERO>"
    exit 1
  fi

  echo "Información del fichero: $1"
  echo "--------------------------------"

  size=$(stat --format="%s" "$1")
  echo "Tamaño: $size bytes"

  tipo=$(stat --format="%F" "$1")
  echo "Tipo: $tipo"

  inodo=$(stat --format="%i" "$1")
  echo "Inodo: $inodo"

  punto_montaje=$(df --output=target "$1" | tail -n 1)
  echo "Punto de montaje: $punto_montaje"
}


#Buscar
buscar(){
  read -p "Introduzca el nombre del fichero a buscar: " fichero

  ruta=$(find / -type f -name "$fichero" 2>/dev/null)

  if [ -z "$ruta" ]; then
    echo "Error: El fichero '$fichero' no existe en el sistema."
    exit 1
  else
    echo "El fichero se encuentra en: $ruta"

    vocales=$(grep -o -i '[aeiou]' "$ruta" | wc -l)
    echo "El fichero contiene $vocales vocales."
  fi
}


#Contar
contar(){
  read -p "Introduzca el directorio donde contar los ficheros: " directorio

  if [ ! -d "$directorio" ]; then
    echo "Error: El directorio '$directorio' no existe."
    exit 1
  fi

  num_ficheros=$(find "$directorio" -type f | wc -l)
  echo "El directorio '$directorio' contiene $num_ficheros ficheros."
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
	    echo "Ha elegido realizar un factorial."
	    factorial "$1"
	   ;;

	   2)clear
             echo "Ha elegido verificar si el año es bisiesto."
             bisiesto "$1"
	   ;;

	   3)clear
             echo "Ha elegido cambiar la configuración de red."
             configurared "$1" "$2" "$3" "$4" "$5"
	   ;;

	   4)clear
	     echo "Ha elegido jugar a Adivina."
	     adivina
	   ;;

	   5)clear
	     echo "Ha elegido mostrar la etapa de su vida."
             edad
	   ;;

	   6)clear
	     echo "Ha elegido mostrar información de un fichero."
             fichero "$1"
	   ;;

	   7)clear
             echo "Ha elegido buscar un fichero y contar sus vocales."
	     buscar
	   ;;

	   8)clear
             echo "Ha elegido contar los fichero de un directorio."
             contar
	   ;;

	   9)

	   ;;

	   10)

	   ;;

	   11)

	   ;;

	   12)

	   ;;

	   13)

	   ;;

	   14)

	   ;;

	   15)

	   ;;

	   16)

	   ;;

	   17)

	   ;;

	   18)

	   ;;

	   19)

	   ;;

	   20)

	   ;;

	   *)clear
	     echo "Opción no válida."
	     sleep 2
	   ;;
	esac








