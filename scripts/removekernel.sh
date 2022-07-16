# /bin/sh

echo "Removing old packages..."
sudo dnf autoremove -y

echo "Removing old kernels..."
echo "The following packages will be removed:"
rpm -q kernel && rpm -q kernel-devel && rpm -q kernel-core && rpm -q kernel-modules

read -p "Are you sure(y/N)? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "yes"
    sudo rpm -e `rpm -q kernel` --nodeps
    sudo rpm -e `rpm -q kernel-devel` --nodeps
    sudo rpm -e `rpm -q kernel-core` --nodeps
    sudo rpm -e `rpm -q kernel-modules` --nodeps
fi