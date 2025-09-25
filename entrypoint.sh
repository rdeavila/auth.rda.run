#!/bin/sh
set -eu

if [ -z "${R2_ACCOUNT_ID:-}" ]; then
  echo "error: R2_ACCOUNT_ID must be set" >&2
  exit 1
fi
if [ -z "${R2_ACCESS_KEY_ID:-}" ]; then
  echo "error: R2_ACCESS_KEY_ID must be set" >&2
  exit 1
fi
if [ -z "${R2_SECRET_ACCESS_KEY:-}" ]; then
  echo "error: R2_SECRET_ACCESS_KEY must be set" >&2
  exit 1
fi
if [ -z "${R2_BUCKET:-}" ]; then
  echo "error: R2_BUCKET must be set" >&2
  exit 1
fi

export AWS_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY}"

R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
R2_BUCKET_PATH="${R2_BUCKET}"
export R2_ENDPOINT R2_BUCKET_PATH

cat > /root/.config/rclone/rclone.conf <<EOS
[r2]
type = s3
provider = Cloudflare
access_key_id = ${R2_ACCESS_KEY_ID}
secret_access_key = ${R2_SECRET_ACCESS_KEY}
endpoint = ${R2_ENDPOINT}
EOS

echo "[init] syncing remote bucket to /app/data…" >&2
rclone sync \
  --create-empty-src-dirs \
  --fast-list \
  "r2:${R2_BUCKET_PATH}" /app/data || true

cat > /usr/local/bin/r2sync-push <<'EOS'
#!/bin/sh
set -e
if [ -z "${R2_ENDPOINT:-}" ] || [ -z "${R2_BUCKET_PATH:-}" ]; then
  echo "R2 environment not configured" >&2
  exit 1
fi
rclone sync \
  --create-empty-src-dirs \
  --fast-list \
  --delete-after \
  --track-renames \
  --metadata \
  /app/data "r2:${R2_BUCKET_PATH}"
EOS
chmod +x /usr/local/bin/r2sync-push

echo "*/5 * * * * /usr/local/bin/r2sync-push >/dev/null 2>&1" > /etc/crontabs/root
crond -f -l 8 &

exec "/usr/local/bin/pocket-id"
