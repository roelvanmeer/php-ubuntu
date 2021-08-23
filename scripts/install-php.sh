cd /tmp || exit
cp /var/lib/dpkg/status /var/lib/dpkg/status-orig
curl -o /tmp/php.sh -sSL https://raw.githubusercontent.com/actions/virtual-environments/main/images/linux/scripts/installers/php.sh
sed -i "s/^php_versions.*/php_versions=$PHP_VERSION/" /tmp/php.sh
sed -i '/ snmp\|php-pear\|composer\|phpunit\|invoke_tests\|source/d' /tmp/php.sh
sudo DEBIAN_FRONTEND=noninteractive bash /tmp/php.sh || true
sudo rm -rf /var/cache/apt/archives/*.deb || true
sudo apt-get install libpcre3-dev libpq-dev unixodbc-dev -y || true
for extension in ast pcov; do
  sudo apt-get install "php$PHP_VERSION-$extension" -y 2>/dev/null || true
done