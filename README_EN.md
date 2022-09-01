# Oh My CentOS Stream 9

A short tutorial about updating `CentOS 8` / `CentOS Stream 8` to `CentOS Stream 9`

[中文](README.md) | [English](README_EN.md)

---

Listen, dude! Did you know? In December 31st, 2021, `CentOS 8` ~~was finished! 🎉🎉🎉~~
Are you still using `CentOS 8`? Why not update to `CentOS Stream 8`, `Rocky Linux 8` or `AlmaLinux` ?

Wait, don't you hear that `CentOS Stream 9` has already released? There are even `Nodejs16` , `Golang1.17.5`, `kernel5.14` and `glic 2.34` package indexes available!

If you pursue new features and a `dnf` package manager, `CentOS Stream 9` is probably your second best choice! (The first one is still `Fedora`)

Unfortunately my VPS provider doesn't provide `CentOS Stream 9` image, or even `CentOS Stream 8` image, so I have to use the outdated `CentOS 8` image, isn't that bad?  

Don't worry, with the method provided in this article, you can also upgrade to `CentOS Stream 9` on `CentOS 8`, with all your data kept and no need to reinstall system!

## How to use

**WARNING**: Upgrading a large version may cause the software or even the system to not work properly, so please be careful!  

**TIPS**: Please read the whole article before you start the operation. If you encounter a problem, you can open an `issue` and create a `pull request` for a better solution.

### Preparation

Use a backup tool you are familiar with to back up your data. If your service provider supports snapshot capabilities, it is highly recommended that you create a snapshot before proceeding.

### Upgrade from `CentOS 8` to `CentOS Stream 8`

The life cycle of `CentOS 8` is over, you can upgrade to `CentOS Stream 8` by the following steps:

Switch to `vault` index, here use the Tsinghua mirror for demo, you can also change to other mirrors you like.

``` sh

minorver=8.5.2111
sudo sed -e "s|^mirrorlist=|#mirrorlist=|g" \
         -e "s|^#baseurl=http://mirror.centos.org/\$contentdir/\$releasever|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-vault/$minorver|g" \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

```

Upgrade `CentOS Stream 8`

``` sh

sudo dnf install \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-4.el8.noarch.rpm \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-release-8.6-1.el8.noarch.rpm \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-4.el8.noarch.rpm \
    -y

sudo dnf distro-sync --allowerasing -y

```

### Upgrade from `CentOS Stream 8` to `CentOS Stream 9`

#### 1. Preparing for RPMs

``` sh

echo "Preparing to download RPMs"
echo "Setting up wget..."
sudo dnf install wget -y

echo "Creating directory ~/cs8to9/el9"
mkdir -p ~/cs8to9/el9
echo "Creating directory ~/cs8to9/epel9"
mkdir -p ~/cs8to9/epel9

echo "Downloading RPMs..."
cd ~/cs8to9/epel9
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
wget https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm

cd ~/cs8to9/el9
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-9.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-9.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-9.el9.noarch.rpm

cd 

``` 

`cs9rpmdownload.sh` can be found in the directory `scripts`. Run the script to execute the command above to automatically download all RPMs.

#### 2. Removing non-essential RPM packages and legacy kernels

``` sh

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

```

`removekernel.sh` can be found in the directory `scripts`. Run the script to execute the command above to automatically remove non-essential RPM packages and lagacy kernels.

#### 3. Upgrading `CentOS Stream 9`

``` sh 

echo "Installing CentOS Stream 9 RPMs..."
cd ~/cs8to9/el9
sudo dnf install centos-stream-release-9.0-9.el9.noarch.rpm centos-stream-repos-9.0-9.el9.noarch.rpm centos-gpg-keys-9.0-9.el9.noarch.rpm -y

echo "Installing EPEL 9 RPMs..."
cd ~/cs8to9/epel9
sudo dnf install epel-release-latest-9.noarch.rpm epel-next-release-latest-9.noarch.rpm -y

echo "Upgrade to CentOS Stream 9..." 
sudo dnf distro-sync --allowerasing -y

echo "cat /etc/redhat-release"
cat /etc/redhat-release

``` 

`cs8to9.sh` can be found in the directory `scripts`. Run the script to execute the command above to automatically upgrade `CentOS Stream 9`.

#### 4. Installing new kernels

``` sh

echo "Rebuilding rpm database..."
sudo rpm --rebuilddb

echo "Reset dnf module cache..."
mkdir -p ~/cs8to9/empty && cd ~/cs8to9/empty
sudo dnf module reset * -y

echo "Installing new kernel..."
sudo dnf install kernel kernel-core kernel-devel kernel-modules -y
sudo dnf groupupdate "Core" "Minimal Install" -y

```

`installkernel.sh` can be found in the directory `scripts`. Run the script to execute the command above to automatically install new kernels.

#### 5. Rebooting the system

Check if the kernel is successfully installed. If so, reboot the system.

``` sh

dnf list --installed | grep -i "kernel"

sudo reboot

```

After the system is rebooted, you can check the new kernel version.


``` sh

uname -a

```

The kernel version should be `5.14`

### 5. Rebuild rescue image

``` sh

echo "Rebuilding rescue image..."
sudo dnf reinstall dracut -y
mkdir -p ~/cs8to9/backup
sudo mv /boot/vmlinuz-0-rescue-* ~/cs8to9/backup
sudo mv /boot/initramfs-0-rescue-*.img ~/cs8to9/backup
sudo /usr/lib/kernel/install.d/51-dracut-rescue.install add $(uname -r) "" /lib/modules/$(uname -r)/vmlinuz

```

`rebuildrescue.sh` can be found in the directory `scripts`. Run the script to execute the command above to automatically rebuild rescue image.

#### 6. (Optional) Reinstall all RPM packages

``` sh

cd ~/cs8to9/empty
sudo dnf reinstall -y *

```

Enjoy your new system!

## License

[![](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)  
OhMyStream9 由 [Ink33](https://github.com/Ink-33) 采用 [知识共享 署名-相同方式共享 4.0 国际 许可协议](http://creativecommons.org/licenses/by-sa/4.0/)进行许可。  

OhMyStream9 by [Ink33](https://github.com/Ink-33) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License.](http://creativecommons.org/licenses/by-sa/4.0/)

### Thanks

Thanks to all the people who already contributed!

<a href="https://github.com/nonebot/nonebot2/graphs/contributors">
<a href="https://github.com/Ink-33/OhMyStream9/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Ink-33/OhMyStream9" />
</a>