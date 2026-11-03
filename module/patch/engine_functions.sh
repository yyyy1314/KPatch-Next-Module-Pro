#!/system/bin/sh
MODROOT=${MODPATH%/patch}
KPNDIR=/data/adb/kp-next

select_engine() {
    case "$1" in 0.13.8|0.13.9) ;; *) echo "! Unsupported engine: $1" >&2; return 1 ;; esac
    ENGINE="$MODROOT/bin/engines/$1"
    [ -s "$ENGINE/kpimg" ] && [ -x "$ENGINE/kptools" ] || return 1
    PATH="$ENGINE:$MODROOT/bin:$PATH"
    export PATH
}

restore_kernel() {
    local info
    info=$("$MODROOT/bin/engines/0.13.9/kptools" -l -i kernel) || return 1
    if echo "$info" | grep -q '^patched=true'; then
        local version
        version=$(echo "$info" | sed -n 's/^version=//p' | head -n 1)
        case "$version" in
            0xd08|d08|0x000d08|0x00000d08) version=0.13.8 ;;
            0xd09|d09|0x000d09|0x00000d09) version=0.13.9 ;;
            *) echo "! Unsupported patched image: $version" >&2; return 1 ;;
        esac
        "$MODROOT/bin/engines/$version/kptools" -u -i kernel -o kernel.clean || return 1
        mv -f kernel.clean kernel || return 1
    elif ! echo "$info" | grep -q '^patched=false'; then
        return 1
    fi
}

backup_boot() {
    mkdir -p "$KPNDIR/backups" || return 1
    cp -f "$BOOTIMAGE" "$KPNDIR/backups/boot-$(date +%Y%m%d-%H%M%S).img"
}
