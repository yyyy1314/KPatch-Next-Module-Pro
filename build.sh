#!/bin/bash

if [[ $1 == "clean" ]]; then
    rm -rf out module/bin module/webroot
    exit 0
fi

mkdir -p out module/bin module/webroot

# Build WebUI
cd webui
pnpm build || pnpm install && pnpm build
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

    local release_json=$(curl -s "$url")
    
    for pattern in "${patterns[@]}"; do
        local regex="${pattern//\*/.*}"
        local asset_data=$(echo "$release_json" | jq -r ".assets[] | select(.name | test(\"$regex\")) | .name + \"\t\" + .browser_download_url" | head -n 1)
        if [[ -z "$asset_data" ]]; then
            echo "Error: Could not find asset matching $pattern in $repo $tag"
            continue
        fi
        local asset_name=$(echo "$asset_data" | cut -f1)
        local download_url=$(echo "$asset_data" | cut -f2)
        echo "Downloading $asset_name from $download_url"
        curl -L "$download_url" -o "module/bin/$asset_name"
    done
}

VERSION_KPATCH_NEXT=$(get_ver "kpatch-next")
VERSION_KPATCH_NEXT="${VERSION_KPATCH_NEXT:-latest}"
VERSION_MAGISKBOOT=$(get_ver "magiskboot")
VERSION_MAGISKBOOT="${VERSION_MAGISKBOOT:-latest}"

# Fetch KPatch-Next binaries
if [[ ! -f "module/bin/kpatch" || ! -f "module/bin/kpimg" || ! -f "module/bin/kptools" ]]; then
    download_assets "yyyy1314/KPatch-Next" "$VERSION_KPATCH_NEXT" "kpatch-android" "kpimg-linux" "kptools-android"

    mv module/bin/kpatch-android module/bin/kpatch
    mv module/bin/kptools-android module/bin/kptools
    mv module/bin/kpimg-linux module/bin/kpimg
fi

# Fetch magiskboot
if [[ ! -f "module/bin/magiskboot" ]]; then
    download_assets "topjohnwu/Magisk" "$VERSION_MAGISKBOOT" "Magisk*.apk"

    APK=$(ls module/bin/Magisk*.apk | head -n 1)
    unzip -p "$APK" 'lib/arm64-v8a/libmagiskboot.so' > "module/bin/magiskboot"
    rm "$APK"
fi

# zip module
commit_number=$(git rev-list --count HEAD)
commit_hash=$(git rev-parse --short HEAD)

cd module
zip -r ../out/KPatch-Next-${commit_number}-${commit_hash}.zip .
cd ..
