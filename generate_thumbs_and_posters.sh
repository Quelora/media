#!/bin/bash

# Configuración
INPUT_DIR="$1"             # Directorio de entrada (pasado como argumento)
THUMBS_DIR="thumbs"        # Carpeta para thumbnails de video
POSTERS_DIR="posters"      # Carpeta para posters WebP
THUMB_DURATION=1           # Duración del thumbnail en segundos
THUMB_QUALITY=30           # Calidad del video (18-32, menor = más compresión)
POSTER_QUALITY=80          # Calidad del WebP (1-100)
POSTER_TIME="00:00:01"     # Tiempo para extraer el poster (ej: 1 segundo)
SCALE="640:-1"             # Escala del thumbnail (ancho:alto automático)

# Verificar si se proporcionó un directorio
if [[ -z "$INPUT_DIR" ]]; then
    echo "❌ Error: Debes especificar un directorio. Ejemplo:"
    echo "  $0 /ruta/al/directorio"
    exit 1
fi

# Verificar si ffmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "❌ Error: FFmpeg no está instalado. Ejecuta: sudo apt install ffmpeg"
    exit 1
fi

# Crear carpetas de salida (si no existen)
mkdir -p "$INPUT_DIR/$THUMBS_DIR" "$INPUT_DIR/$POSTERS_DIR"

# Procesar todos los archivos MP4 en el directorio de entrada
for video in "$INPUT_DIR"/*.mp4; do
    if [[ "$video" == *"_thumb.mp4" ]]; then
        continue  # Ignorar archivos que ya son thumbnails
    fi

    # Nombre base (sin extensión ni ruta)
    base_name=$(basename "$video" .mp4)

    # 1. Generar thumbnail de video (1 segundo, baja calidad)
    echo "🔄 Procesando thumbnail para: $base_name.mp4"
    ffmpeg -i "$video" \
           -ss "$POSTER_TIME" \
           -t "$THUMB_DURATION" \
           -c:v libx264 \
           -crf "$THUMB_QUALITY" \
           -preset ultrafast \
           -an \
           -vf "scale=$SCALE" \
           "$INPUT_DIR/$THUMBS_DIR/${base_name}_thumb.mp4" -y

    # 2. Extraer poster en WebP (optimizado para web)
    echo "🖼️ Generando poster WebP para: $base_name.mp4"
    ffmpeg -i "$video" \
           -ss "$POSTER_TIME" \
           -vframes 1 \
           -q:v "$POSTER_QUALITY" \
           -vf "scale=$SCALE" \
           "$INPUT_DIR/$POSTERS_DIR/${base_name}.webp" -y

    echo "✅ $base_name: ¡Thumb y poster generados!"
done

echo "🎉 ¡Proceso completado! Archivos guardados en:"
echo "   - Thumbnails: $INPUT_DIR/$THUMBS_DIR/"
echo "   - Posters:    $INPUT_DIR/$POSTERS_DIR/"