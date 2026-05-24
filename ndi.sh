#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# ========= CONFIG =========
newUser="USERNAME"
debs_url="http://git.indevlin.com/res/debs"

# detect chassis type
chassis=$(hostnamectl | awk -F: '/Chassis/ {gsub(/^[ \t]+/, "", $2); print tolower($2)}')

# ========= SYSTEM UPDATE =========
apt-get update
apt-get upgrade -y

# ========= INSTALL REPO PACKAGES =========
install_from_file() {
    local file="$1"
    local fail_log="./install_fails.txt"

    [[ -f "$file" ]] || return 0

    mapfile -t pkgs < <(grep -vE '^\s*#|^\s*$' "$file")

    (( ${#pkgs[@]} > 0 )) || return 0

    : > "$fail_log"

    local pkg
    for pkg in "${pkgs[@]}"; do
        echo "Installing: $pkg"

        if ! apt-get install -y "$pkg"; then
            echo "$pkg" >> "$fail_log"
            echo "FAILED: $pkg"
        fi
    done
}

install_from_file "packages_install.txt"

# ========= THINKPAD-SPECIFIC PACKAGES =========
# Only apply if chassis looks like a laptop and vendor hints ThinkPad
if [[ "$chassis" == "laptop" ]] && grep -qi "thinkpad" /sys/devices/virtual/dmi/id/product_name 2>/dev/null; then
    echo "ThinkPad detected → installing ThinkPad-specific packages"
    install_from_file "thinkpad_packages_install.txt"
fi

# ========= LOCAL DEB INSTALL (ROBUST) =========
tmp_dir=$(mktemp -d)

if [[ -f "debs.txt" ]]; then
    mapfile -t debs < <(grep -vE '^\s*#|^\s*$' debs.txt)

    for line in "${debs[@]}"; do
        file_url="${debs_url}/${line}"
        out_file="$tmp_dir/$(basename "$line")"

        if ! wget -q "$file_url" -O "$out_file"; then
            echo "Download failed: $file_url" >&2
        fi
    done

    # install all at once (dependency-aware)
    if compgen -G "$tmp_dir/*.deb" > /dev/null; then
        dpkg -i "$tmp_dir"/*.deb
    fi
fi

rm -rf "$tmp_dir"

# ========= FINAL DEPENDENCY FIX =========
apt-get -f install -y

# ========= CLEANUP & FULL UPGRADE =========
apt-get autoremove --purge -y
apt-get dist-upgrade -y

# ========= REMOVE UNWANTED PACKAGES =========
remove_from_file() {
    local file="$1"

    [[ -f "$file" ]] || return 0

    mapfile -t pkgs < <(grep -vE '^\s*#|^\s*$' "$file")

    if (( ${#pkgs[@]} > 0 )); then
        apt-get purge -y "${pkgs[@]}"
    fi
}

remove_from_file "packages_remove.txt"

# ========= USER SETUP =========
if ! id -u "$newUser" >/dev/null 2>&1; then
    if [[ -d "/home/$newUser" ]]; then
        useradd -M -U "$newUser"
    else
        useradd -m -U "$newUser"
    fi
fi

# ensure shell
chsh -s /bin/bash "$newUser"

# copy skeleton files (don’t fail if empty)
if [[ -d "home" ]]; then
    cp -R home/* "/home/$newUser/" 2>/dev/null || true
fi

chown -R "$newUser:$newUser" "/home/$newUser"

# group memberships
usermod -a -G adm,audio,backup,bluetooth,cdrom,dialout,dip,disk,fax,floppy,games,lpadmin,mail,netdev,operator,plugdev,root,scanner,staff,sudo,tape,users,uucp,video,voice,www-data "$newUser"

exit 0
