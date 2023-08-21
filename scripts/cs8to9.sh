# /bin/sh

echo "Installing CentOS Stream 9 RPMs..."
cd ~/cs8to9/el9
sudo dnf install centos-stream-release-9.0-22.el9.noarch.rpm centos-stream-repos-9.0-22.el9.noarch.rpm centos-gpg-keys-9.0-22.el9.noarch.rpm -y

echo "Installing EPEL 9 RPMs..."
cd ~/cs8to9/epel9
sudo dnf install epel-release-latest-9.noarch.rpm epel-next-release-latest-9.noarch.rpm -y

echo "Upgrade to CentOS Stream 9..." 
sudo dnf distro-sync --allowerasing -y

echo "cat /etc/redhat-release"
cat /etc/redhat-release
