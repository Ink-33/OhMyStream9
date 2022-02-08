# /bin/sh

echo "Rebuilding rpm database..."
sudo rpm --rebuilddb

echo "Reset dnf module cache..."
mkdir -p ~/cs8to9/empty && cd ~/cs8to9/empty
sudo dnf module reset * -y

echo "Installing new kernel..."
sudo dnf install kernel kernel-core kernel-devel kernel-modules -y
