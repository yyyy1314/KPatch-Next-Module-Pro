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

VERSION_MAGISKBOOT=$(get_ver "magiskboot")
VERSION_MAGISKBOOT="${VERSION_MAGISKBOOT:-latest}"
for version in 0.13.8 0.13.9; do
    for tool in kpimg kptools kpatch; do
        [ -s "module/bin/engines/$version/$tool" ] || { echo "Missing $version/$tool; build engines first"; exit 1; }
    done
done
cp module/engine-tool.sh module/bin/kpatch
cp module/engine-tool.sh module/bin/kptools
# Fetch magiskboot
if [[ ! -f "module/bin/magiskboot" ]]; then
    download_assets "topjohnwu/Magisk" "$VERSION_MAGISKBOOT" "Magisk*.apk" || exit 1

    APK=$(ls module/bin/Magisk*.apk | head -n 1)
    unzip -p "$APK" 'lib/arm64-v8a/libmagiskboot.so' > "module/bin/magiskboot" || exit 1
    rm "$APK"
fi

# zip module
VERSION=$(sed -n 's/^version=//p' module/module.prop)
for tool in kpatch kptools magiskboot; do
    [ -s "module/bin/$tool" ] || exit 1
done
chmod 755 module/bin/kpatch module/bin/kptools module/bin/magiskboot module/bin/engines/*/kpatch module/bin/engines/*/kptools
rm -f module/bin/kpimg
rm -f "out/KPatch-Next-Module-Pro-${VERSION}.zip"
(cd module && zip -r "../out/KPatch-Next-Module-Pro-${VERSION}.zip" .)
