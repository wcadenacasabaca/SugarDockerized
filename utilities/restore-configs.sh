#!/bin/bash

# === Variables ===
# Permitir pasar BASE_DIR y BACKUP_NAME como parámetros
BASE_DIR=${1}
BACKUP_NAME=${2}

# Si no se pasa BASE_DIR, calcularlo automáticamente
if [ -z "$BASE_DIR" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BASE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
fi

BACKUPS_DIR="$BASE_DIR/backups/configs"

# === Función para restaurar archivos ===
restaurar_backup() {
  local backup_path="$1"

  echo "🚀 Restaurando backup desde: $backup_path"

  # Buscar todos los archivos dentro del backup/data/app
  find "$backup_path/data/app" -type f | while read -r archivo_backup; do
    # Obtener ruta relativa eliminando $backup_path/data/app
    local ruta_relativa="${archivo_backup#$backup_path/data/app/}"
    local destino="$BASE_DIR/data/app/$ruta_relativa"

    mkdir -p "$(dirname "$destino")"
    cp "$archivo_backup" "$destino"
    echo "✅ Archivo restaurado en: $destino"
  done

  echo "🏁 Restauración finalizada."
}

# === Inicio ===
echo "🛡️ Iniciando proceso de restauración en: $BASE_DIR"

# Verificar que existan backups
if [ ! -d "$BACKUPS_DIR" ]; then
  echo "❌ No se encontró la carpeta de backups: $BACKUPS_DIR"
  exit 1
fi

# Si no pasaron nombre del backup como parámetro, preguntar
if [ -z "$BACKUP_NAME" ]; then
  echo "📂 Backups disponibles:"
  ls -1 "$BACKUPS_DIR"

  echo ""
  read -rp "🛑 Ingresa el nombre del backup que deseas restaurar (ejemplo: 20250428_082503): " BACKUP_NAME
fi

backup_path="$BACKUPS_DIR/$BACKUP_NAME"

# Verificar si el backup seleccionado existe
if [ ! -d "$backup_path" ]; then
  echo "❌ Backup no encontrado: $backup_path"
  exit 1
fi

# Ejecutar restauración
restaurar_backup "$backup_path"
