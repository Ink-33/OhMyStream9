# /bin/sh

echo "Rebuilding rescue image..."
sudo dnf reinstall dracut -y
mkdir -p ~/cs8to9/backup
sudo mv /boot/vmlinuz-0-rescue-* ~/cs8to9/backup
sudo mv /boot/initramfs-0-rescue-*.img ~/cs8to9/backup
sudo /usr/lib/kernel/install.d/51-dracut-rescue.install add $(uname -r) "" /lib/modules/$(uname -r)/vmlinuz
