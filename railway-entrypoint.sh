#!/bin/sh
set -eu

APP_HOME="${APP_HOME:-/home/node/app}"
PERSIST_DIR="${LUKER_PERSIST_DIR:-/data}"
PORT_VALUE="${PORT:-8000}"
AUTH_USER="${LUKER_USERNAME:-${SILLYTAVERN_BASICAUTHUSER_USERNAME:-luker}}"
AUTH_PASS="${LUKER_PASSWORD:-${SILLYTAVERN_BASICAUTHUSER_PASSWORD:-}}"

if [ -z "$AUTH_PASS" ]; then
  printf '%s\n' "LUKER_PASSWORD is required. Set it in Railway variables before starting Luker." >&2
  exit 1
fi

export SILLYTAVERN_BASICAUTHUSER_USERNAME="$AUTH_USER"
export SILLYTAVERN_BASICAUTHUSER_PASSWORD="$AUTH_PASS"
export SILLYTAVERN_BASICAUTHMODE="true"
export SILLYTAVERN_WHITELISTMODE="false"
export SILLYTAVERN_BROWSERLAUNCH_ENABLED="false"
export SILLYTAVERN_LISTEN="true"
export SILLYTAVERN_PORT="$PORT_VALUE"

mkdir -p "$PERSIST_DIR"
cd "$APP_HOME"

persist_dir() {
  app_path="$1"
  data_path="$2"

  mkdir -p "$(dirname "$app_path")" "$data_path"

  if [ -d "$app_path" ] && [ ! -L "$app_path" ] && [ -z "$(ls -A "$data_path" 2>/dev/null)" ]; then
    cp -a "$app_path"/. "$data_path"/ 2>/dev/null || true
  fi

  rm -rf "$app_path"
  ln -s "$data_path" "$app_path"
}

persist_dir "$APP_HOME/config" "$PERSIST_DIR/config"
persist_dir "$APP_HOME/data" "$PERSIST_DIR/data"
persist_dir "$APP_HOME/plugins" "$PERSIST_DIR/plugins"
persist_dir "$APP_HOME/public/scripts/extensions/third-party" "$PERSIST_DIR/extensions"
persist_dir "$APP_HOME/backups" "$PERSIST_DIR/backups"

if [ "$(id -u)" = "0" ]; then
  chown -R node:node "$PERSIST_DIR" 2>/dev/null || true
fi

exec ./docker-entrypoint.sh \
  --port="$PORT_VALUE" \
  --browserLaunchEnabled=false \
  --whitelist=false \
  --basicAuthMode=true \
  "$@"
