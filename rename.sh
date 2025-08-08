#!/bin/bash

DIR="$1"

if [[ -z "$DIR" ]]; then
    echo "❌ Error: Debes especificar un directorio."
    echo "Ejemplo: $0 /ruta/al/directorio"
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    echo "❌ Error: '$DIR' no es un directorio válido."
    exit 1
fi

shopt -s nullglob
files=("$DIR"/*)
if [ ${#files[@]} -eq 0 ]; then
    echo "⚠️ No hay archivos en el directorio '$DIR'."
    exit 0
fi

counter=1

for filepath in "${files[@]}"; do
    # Evitar directorios
    if [[ -d "$filepath" ]]; then
        continue
    fi

    filename=$(basename -- "$filepath")
    extension="${filename##*.}"

    if [[ "$filename" == "$extension" ]]; then
        extension=""
        newname="$counter"
    else
        newname="$counter.$extension"
    fi

    newpath="$DIR/$newname"

    if [[ -e "$newpath" ]]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        if [[ -z "$extension" ]]; then
            newname="${counter}_(${timestamp})"
        else
            newname="${counter}_(${timestamp}).${extension}"
        fi
        newpath="$DIR/$newname"
    fi

    mv "$filepath" "$newpath"
    ((counter++))
done

echo "✅ Renombrado completado."
