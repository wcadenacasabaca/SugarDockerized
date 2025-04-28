#!/bin/bash

# === Variables ===
BASE_DIR=${1:-~/code/docker/SugarDockerized}
BACKUP_DIR="$BASE_DIR/backups/configs/$(date +%Y%m%d_%H%M%S)"

# === Función para respaldar archivos manteniendo la estructura ===
respaldar_archivo() {
  local archivo=$1
  if [ -f "$archivo" ]; then
    local ruta_relativa="${archivo#$BASE_DIR/}"  # Elimina el BASE_DIR de la ruta
    local destino="$BACKUP_DIR/$ruta_relativa"

    mkdir -p "$(dirname "$destino")"
    cp "$archivo" "$destino"
    echo "✅ Archivo respaldado en: $destino"
  else
    echo "⚠️  Archivo no encontrado: $archivo. No se pudo respaldar."
  fi
}

# === Inicio ===
echo "🛡️ Iniciando respaldo de configuraciones en: $BASE_DIR"

respaldar_archivo "$BASE_DIR/data/app/laravel/sugarAPI/.env"

respaldar_archivo "$BASE_DIR/data/app/custom/.htaccess"
respaldar_archivo "$BASE_DIR/data/app/custom/custom/Backend/Config.php"

respaldar_archivo "$BASE_DIR/data/app/sugar/config.php"
respaldar_archivo "$BASE_DIR/data/app/sugar/config_override.php"
respaldar_archivo "$BASE_DIR/data/app/sugar/.htaccess"

echo "🏁 Respaldo completado. Archivos guardados en: $BACKUP_DIR"
