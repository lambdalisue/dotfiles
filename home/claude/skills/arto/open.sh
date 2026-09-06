#!/bin/sh
# Open files or directories in Arto without blocking the caller.
#
# `arto PATH` returns immediately only when an Arto instance is already
# running (the CLI forwards the request to it). Without a running instance
# the CLI process *becomes* the app and never returns, which would hang the
# shell that invoked it. So: forward when running, otherwise let
# LaunchServices start a detached instance with the same argv.
#
# Positional paths and --directory values are made absolute first, because a
# LaunchServices-started app has no meaningful working directory.

set -eu

APP_EXE="/Applications/Arto.app/Contents/MacOS/arto"

abspath() {
  if [ -d "$1" ]; then
    (cd "$1" && pwd -P)
  else
    printf '%s/%s\n' "$(cd "$(dirname "$1")" && pwd -P)" "$(basename "$1")"
  fi
}

# Rebuild "$@" with absolute paths.
i=0
n=$#
while [ "$i" -lt "$n" ]; do
  arg=$1
  shift
  case "$arg" in
    --directory=*) arg="--directory=$(abspath "${arg#--directory=}")" ;;
    --directory)
      set -- "$@" "$arg"
      arg=$(abspath "$1")
      shift
      i=$((i + 1))
      ;;
    -*) ;;
    *) arg=$(abspath "$arg") ;;
  esac
  set -- "$@" "$arg"
  i=$((i + 1))
done

if pgrep -f "$APP_EXE" >/dev/null 2>&1; then
  exec "$APP_EXE" "$@"
else
  exec open -a Arto --args "$@"
fi
