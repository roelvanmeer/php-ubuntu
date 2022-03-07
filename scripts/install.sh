#!/usr/bin/env bash

get() {
  file_path=$1
  shift
  links=("$@")
  for link in "${links[@]}"; do
    status_code=$(sudo curl -w "%{http_code}" -o "$file_path" -sL "$link")
    [ "$status_code" = "200" ] && break
  done
}

install() {
  get /tmp/"$tar_file" "https://github.com/shivammathur/php-ubuntu/releases/latest/download/$tar_file" "https://dl.cloudsmith.io/public/shivammathur/php-ubuntu/raw/files/$tar_file"
  sudo cp /var/lib/dpkg/status /var/lib/dpkg/status-orig
  sudo rm -rf /var/lib/apt/lists/*ondrej*
  sudo tar -I zstd -xf /tmp/"$tar_file" -C /
  sudo LC_ALL=C.UTF-8 python3 /usr/sbin/merge_status && sudo rm -f /usr/sbin/merge_status
  sudo mv /var/lib/dpkg/status-orig /var/lib/dpkg/status
}

fix_service() {
  if [ "$reload" = "true" ]; then
    sudo systemctl daemon-reload 2>/dev/null || true
    sudo systemctl start php"$version"-fpm 2>/dev/null || true
  fi
}

check_reload() {
  if ! [ -e /lib/systemd/system/php"$version"-fpm.service ]; then
    reload=true
  fi
  if [ "$(readlink -f /etc/systemd/system/php"$version"-fpm.service)" = "/dev/null" ]; then
    sudo rm -f /etc/systemd/system/php"$version"-fpm.service
    reload=true
  fi
}

. /etc/os-release
version=$1
tar_file=php_"$version"+ubuntu"$VERSION_ID".tar.zst
check_reload
install
fix_service
