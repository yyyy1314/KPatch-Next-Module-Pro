#!/system/bin/sh
BINDIR=${0%/*}
TOOL=${0##*/}
VERSION=${KPATCH_ENGINE:-0.13.9}
if [ "$TOOL" = kpatch ] && [ -z "$KPATCH_ENGINE" ]; then
    RAW=$("$BINDIR/engines/0.13.9/kpatch" kpver 2>/dev/null)
    case "$RAW" in
        d08|0xd08|0x000d08|0x00000d08) VERSION=0.13.8 ;;
    esac
fi
exec "$BINDIR/engines/$VERSION/$TOOL" "$@"
