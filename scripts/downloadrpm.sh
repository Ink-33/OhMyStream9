# /bin/sh

echo "Preparing to download RPMs"
echo "Setting up wget..."
sudo dnf install wget -y

echo "Creating directory ~/rpms/el9"
mkdir -p ~/rpms/el9
echo "Creating directory ~/rpms/epel9"
mkdir -p ~/rpms/epel9

echo "Downloading RPMs..."
cd ~/rpms/epel9
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
wget https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm

cd ~/rpms/el9
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-9.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-9.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-9.el9.noarch.rpm
