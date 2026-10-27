#!/bin/bash

if [[ $1 == "clean" ]]; then
    rm -rf out module/bin module/webroot
    exit 0
fi

mkdir -p out module/bin module/webroot

# Build WebUI
cd webui
pnpm install --frozen-lockfile && pnpm build || exit 1
cd ..

# Read versions from version.properties
get_ver() {
    [ -f version.properties ] && grep "^$1[[:space:]]*=" version.properties | cut -d'=' -f2 | xargs | sed 's/^"//;s/"$//'
}

download_assets() {
    local repo="$1"
    local tag="$2"
    shift 2
    local patterns=("$@")

    local url="https://api.github.com/repos/$repo/releases"
    if [[ "$tag" == "latest" ]]; then
        url="$url/latest"
    else
        url="$url/tags/$tag"
    fi

    local release_json
    release_json=$(curl -fsSL "$url") || return 1
    
    for pattern in "${patterns[@]}"; do
        local regex="${pattern//\*/.*}"
        local asset_data=$(echo "$release_json" | jq -r ".assets[] | select(.name | test(\"$regex\")) | .name + \"\t\" + .browser_download_url" | head -n 1)
        if [[ -z "$asset_data" ]]; then
            echo "Error: Could not find asset matching $pattern in $repo $tag"
            return 1
        fi
        local asset_name=$(echo "$asset_data" | cut -f1)
        local download_url=$(echo "$asset_data" | cut -f2)
        echo "Downloading $asset_name from $download_url"
        curl -fL "$download_url" -o "module/bin/$asset_name" || return 1
    done
}

VERSION_KPATCH_NEXT=$(get_ver "kpatch-next")
VERSION_KPATCH_NEXT="${VERSION_KPATCH_NEXT:-latest}"
VERSION_MAGISKBOOT=$(get_ver "magiskboot")
VERSION_MAGISKBOOT="${VERSION_MAGISKBOOT:-latest}"

# Fetch KPatch-Next binaries
if [[ ! -f "module/bin/kpatch" || ! -f "module/bin/kpimg" || ! -f "module/bin/kptools" ]]; then
    download_assets "yyyy1314/KPatch-Next-Pro" "$VERSION_KPATCH_NEXT" "kpatch-android" "kpimg-linux" "kptools-android" || exit 1

    mv module/bin/kpatch-android module/bin/kpatch
    mv module/bin/kptools-android module/bin/kptools
    mv module/bin/kpimg-linux module/bin/kpimg
fi

# Fetch magiskboot
if [[ ! -f "module/bin/magiskboot" ]]; then
    download_assets "topjohnwu/Magisk" "$VERSION_MAGISKBOOT" "Magisk*.apk" || exit 1

    APK=$(ls module/bin/Magisk*.apk | head -n 1)
    unzip -p "$APK" 'lib/arm64-v8a/libmagiskboot.so' > "module/bin/magiskboot" || exit 1
    rm "$APK"
fi

# zip module
VERSION=$(sed -n 's/^version=//p' module/module.prop)
for tool in kpatch kpimg kptools magiskboot; do
    [ -s "module/bin/$tool" ] || exit 1
done
chmod 755 module/bin/kpatch module/bin/kptools module/bin/magiskboot
rm -f "out/KPatch-Next-Module-Pro-${VERSION}.zip"
(cd module && zip -r "../out/KPatch-Next-Module-Pro-${VERSION}.zip" .)
