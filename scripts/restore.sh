#!/usr/bin/env bash
# =====================================================================
# restore.sh — Restauración de copia de seguridad (RA3 · práctica 2)
#
# Sin argumentos: lista las copias disponibles en backups/
# Con marca de fecha (AAAAMMDD-HHMMSS): restaura la base de datos en
# MariaDB y sustituye wp-content en WordPress previa confirmación (SI).
#
# Uso:
#   ./scripts/restore.sh
#   ./scripts/restore.sh AAAAMMDD-HHMMSS
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")/.."

ORIGEN="backups"

# Sin argumentos: listar las marcas de fecha disponibles
if [ $# -eq 0 ]; then
  echo "== Copias disponibles en $ORIGEN/ =="
  if [ ! -d "$ORIGEN" ] || ! ls "$ORIGEN"/db_*.sql.gz >/dev/null 2>&1; then
    echo "No hay ninguna copia de seguridad disponible."
    exit 0
  fi

  for f_db in $(ls -1t "$ORIGEN"/db_*.sql.gz); do
    marca="${f_db#"$ORIGEN/db_"}"
    marca="${marca%.sql.gz}"
    if [ -f "$ORIGEN/wp-content_$marca.tar.gz" ]; then
      tam_db="$(du -h "$f_db" | cut -f1)"
      tam_wp="$(du -h "$ORIGEN/wp-content_$marca.tar.gz" | cut -f1)"
      echo "  $marca   (DB: $tam_db | wp-content: $tam_wp)"
    fi
  done

  echo ""
  echo "Para restaurar una copia ejecuta: ./scripts/restore.sh AAAAMMDD-HHMMSS"
  exit 0
fi

FECHA="$1"
F_DB="$ORIGEN/db_$FECHA.sql.gz"
F_WP="$ORIGEN/wp-content_$FECHA.tar.gz"

# 1. Comprobar que existen ambos ficheros y no están corruptos
if [ ! -f "$F_DB" ] || [ ! -f "$F_WP" ]; then
  echo "ERROR: no se encontró el par completo de copia para '$FECHA' en $ORIGEN/." >&2
  echo "Ejecuta ./scripts/restore.sh sin parámetros para ver las fechas válidas." >&2
  exit 1
fi

gzip -t "$F_DB" "$F_WP"

# 2. Comprobar que los servicios necesarios están en marcha
for servicio in db wordpress; do
  if ! docker compose ps --status running --services | grep -qx "$servicio"; then
    echo "ERROR: el servicio '$servicio' no está en marcha. Ejecuta: docker compose up -d" >&2
    exit 1
  fi
done

# 3. Pedir confirmación explícita antes de sobrescribir
echo "ATENCIÓN: se va a sobrescribir la base de datos y /var/www/html/wp-content"
echo "con la copia del $FECHA. Los cambios posteriores se perderán."
read -r -p "Escribe SI para continuar: " CONFIRMACION
if [ "$CONFIRMACION" != "SI" ]; then
  echo "Restauración cancelada."
  exit 0
fi

echo "== Restaurando copia $FECHA =="

# 4. Restaurar la base de datos en MariaDB
echo "-> Cargando volcado en MariaDB..."
gunzip -c "$F_DB" | docker compose exec -T db sh -c '
  : "${WP_DB_USER:?falta WP_DB_USER en .env}" "${WP_DB_NAME:?falta WP_DB_NAME en .env}"
  exec mariadb -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"'

# 5. Sustituir wp-content por el de la copia y asegurar permisos de www-data
echo "-> Sustituyendo wp-content..."
docker compose exec -T wordpress sh -c 'rm -rf /var/www/html/wp-content/* /var/www/html/wp-content/.[!.]* /var/www/html/wp-content/..?*'
docker compose exec -T wordpress tar -xzf - -C /var/www/html < "$F_WP"
docker compose exec -T wordpress chown -R www-data:www-data /var/www/html/wp-content

echo "OK. Copia $FECHA restaurada correctamente."
