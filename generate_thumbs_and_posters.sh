#!/bin/bash
set -o pipefail

INPUT_DIR="$1"
THUMBS_DIR="thumbs"
POSTERS_DIR="posters"
THUMB_DURATION=3
THUMB_QUALITY=30
POSTER_QUALITY=80
POSTER_TIME="00:00:01"
SCALE="640:trunc(ow/a/2)*2"

if [[ -z "$INPUT_DIR" ]]; then
    echo "❌ Error: Debes especificar un directorio. Ejemplo:"
    echo "  $0 /ruta/al/directorio"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ Error: FFmpeg no está instalado. Ejecuta: sudo apt install ffmpeg"
    exit 1
fi

mkdir -p "$INPUT_DIR/$THUMBS_DIR" "$INPUT_DIR/$POSTERS_DIR"

shopt -s nullglob

total=0
skipped=0
errors=0
success=0

for video in "$INPUT_DIR"/*.mp4; do
    ((total++))

    if [[ "$video" == *"_thumb.mp4" ]]; then
        ((skipped++))
        continue
    fi

    base_name=$(basename "$video" .mp4)

    # Generar thumbnail
    if ! ffmpeg -i "$video" \
           -ss "$POSTER_TIME" \
           -t "$THUMB_DURATION" \
           -c:v libx264 \
           -crf "$THUMB_QUALITY" \
           -preset ultrafast \
           -an \
           -vf "scale=$SCALE" \
           "$INPUT_DIR/$THUMBS_DIR/${base_name}_thumb.mp4" -y \
           -loglevel error; then
        echo "❌ Error al generar thumbnail para: $base_name.mp4"
        ((errors++))
        continue
    fi

    # Generar poster WebP
    if ! ffmpeg -i "$video" \
           -ss "$POSTER_TIME" \
           -vframes 1 \
           -q:v "$POSTER_QUALITY" \
           -vf "scale=$SCALE" \
           "$INPUT_DIR/$POSTERS_DIR/${base_name}.webp" -y \
           -loglevel error; then
        echo "❌ Error al generar poster WebP para: $base_name.mp4"
        ((errors++))
        continue
    fi

    ((success++))
done

echo "📊 Resumen:"
echo "   Total archivos encontrados: $total"
echo "   Ignorados (thumbnails existentes): $skipped"
echo "   Procesados con éxito: $success"
echo "   Errores: $errors"
