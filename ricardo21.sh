#!/bin/bash

# Definición de variables
REPOSITORIOS=("Fotografia" "Dibujo" "Imagenes")
EXTENSIONES=("jpg" "gif" "png")
LOG_FILE="descartados.log"

# Función para verificar si una extensión es válida
es_extension_valida() {
    local extension=$1
    for ext in "${EXTENSIONES[@]}"; do
        if [ "$extension" = "$ext" ]; then
            return 0
        fi
    done
    return 1
}

# Función para obtener el formato real del archivo usando file
obtener_formato_real() {
    local archivo=$1
    # Ejecutamos file -i y extraemos solo el tipo de mime
    local tipo=$(file -i "$archivo" | grep -o "image/[a-z]*")
    
    case $tipo in
        "image/jpeg") echo "jpg";;
        "image/gif") echo "gif";;
        "image/png") echo "png";;
        *) echo "invalid";;
    esac
}

# Función para procesar un archivo
procesar_archivo() {
    local archivo=$1
    local extension="${archivo##*.}"
    local nombre_base="${archivo%.*}"
    local formato_real=$(obtener_formato_real "$archivo")
    
    # Si el formato no es válido, eliminar y registrar
    if [ "$formato_real" = "invalid" ]; then
        echo "$(whoami):$(groups):$(date +%d.%m.%Y):$archivo" >> "$LOG_FILE"
        rm "$archivo"
        echo "Archivo $archivo eliminado por formato inválido"
        return
    fi
    
    # Si la extensión no coincide con el formato real, renombrar
    if [ "$extension" != "$formato_real" ]; then
        mv "$archivo" "$nombre_base.$formato_real"
        echo "Archivo $archivo renombrado a $nombre_base.$formato_real"
    fi
}

# Verificar si se proporcionó un parámetro
if [ $# -ne 1 ]; then
    echo "Uso: $0 <nombre_alumno>"
    exit 1
fi

ALUMNO=$1
TOTAL_ARCHIVOS=0

# Procesar cada repositorio
for repo in "${REPOSITORIOS[@]}"; do
    if [ -d "$repo" ]; then
        echo "Procesando repositorio $repo"
        # Buscar archivos del alumno en el repositorio
        find "$repo" -type f -user "$ALUMNO" | while read archivo; do
            procesar_archivo "$archivo"
            ((TOTAL_ARCHIVOS++))
        done
    fi
done

echo "Total de archivos procesados para $ALUMNO: $TOTAL_ARCHIVOS"
