#!/bin/bash

# Definición de variables
LOG_ERROR="bajaserror.log"
LOG_BAJAS="bajas.log"
PROYECTO_DIR="/home/proyecto"

# Función para validar el archivo de entrada
validar_parametro() {
    # Comprobar que se pasa un parámetro
    if [ $# -ne 1 ]; then
        echo "ERROR: Se debe proporcionar un archivo como parámetro"
        exit 1
    fi
    
    # Comprobar que el archivo existe
    if [ ! -f "$1" ]; then
        echo "ERROR: El archivo $1 no existe"
        exit 1
    fi
}

# Función para registrar error
registrar_error() {
    local login=$1
    local nombre=$2
    local apellidos=$3
    local fecha=$(date '+%d/%m/%Y-%H:%M:%S')
    echo "$fecha-$login-$nombre-$apellidos-ERROR:login no existe en el sistema" >> "$LOG_ERROR"
}

# Función para mover archivos del usuario
mover_archivos() {
    local login=$1
    local user_dir="/home/$login"
    local backup_dir="$PROYECTO_DIR/$login"
    local total_archivos=0
    
    # Crear directorio de backup
    mkdir -p "$backup_dir"
    
    # Mover archivos del directorio trabajo
    if [ -d "$user_dir/trabajo" ]; then
        # Contar y mover archivos
        total_archivos=$(find "$user_dir/trabajo" -type f | wc -l)
        mv "$user_dir/trabajo"/* "$backup_dir/" 2>/dev/null
        
        # Registrar en el log
        echo "$(date '+%d/%m/%Y-%H:%M:%S')-$login-$backup_dir" >> "$LOG_BAJAS"
        # Listar archivos movidos
        find "$backup_dir" -type f | awk '{print NR":"$0}' >> "$LOG_BAJAS"
        echo "Total de ficheros movidos: $total_archivos" >> "$LOG_BAJAS"
    fi
    
    return $total_archivos
}

# Función para procesar un usuario
procesar_usuario() {
    local linea=$1
    local nombre=$(echo "$linea" | cut -d: -f1)
    local apellido1=$(echo "$linea" | cut -d: -f2)
    local apellido2=$(echo "$linea" | cut -d: -f3)
    local login=$(echo "$linea" | cut -d: -f4)
    
    # Verificar si el usuario existe
    if id "$login" >/dev/null 2>&1; then
        # Mover archivos
        mover_archivos "$login"
        
        # Eliminar usuario y su directorio home
        userdel -r "$login" 2>/dev/null
        
        echo "Usuario $login eliminado correctamente"
    else
        registrar_error "$login" "$nombre" "$apellido1 $apellido2"
        echo "Error: Usuario $login no existe"
    fi
}

# Verificar los parámetros
validar_parametro "$@"
archivo_bajas=$1

# Verificar que el archivo no está vacío
if [ ! -s "$archivo_bajas" ]; then
    echo "ERROR: El archivo está vacío"
    exit 1
fi

# Procesar cada línea del archivo
while IFS= read -r linea || [ -n "$linea" ]; do
    # Verificar formato de la línea
    if [[ "$linea" =~ ^[^:]+:[^:]+:[^:]+:[^:]+$ ]]; then
        procesar_usuario "$linea"
    else
        echo "ERROR: Línea con formato incorrecto: $linea"
    fi
done < "$archivo_bajas"

# Establecer root como propietario de los archivos movidos
chown -R root:root "$PROYECTO_DIR"/*

echo "Proceso de bajas completado"
