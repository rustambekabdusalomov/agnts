#!/bin/sh
# Nightly pg_dump at 03:00 (container TZ), keeping BACKUP_KEEP_DAYS days.
# Copy /backups off the server too; a backup on the same disk is not a backup.
set -eu

keep_days="${BACKUP_KEEP_DAYS:-14}"

dump() {
  ts=$(date +%Y-%m-%dT%H%M)
  tmp="/backups/.hiro-$ts.dump.partial"
  if pg_dump --format=custom --file="$tmp"; then
    mv "$tmp" "/backups/hiro-$ts.dump"
    echo "backup: wrote hiro-$ts.dump ($(du -h "/backups/hiro-$ts.dump" | cut -f1))"
  else
    rm -f "$tmp"
    echo "backup: pg_dump FAILED" >&2
  fi
  find /backups -name 'hiro-*.dump' -mtime +"$keep_days" -print -delete
}

while :; do
  now=$(date +%s)
  next=$(date -d "$(date +%Y-%m-%d) 03:00" +%s 2>/dev/null || date -D '%Y-%m-%d %H:%M' -d "$(date +%Y-%m-%d) 03:00" +%s)
  [ "$next" -le "$now" ] && next=$((next + 86400))
  echo "backup: next run in $(( (next - now) / 60 )) min"
  sleep $((next - now))
  dump
done
