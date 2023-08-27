# Oh My CentOS Stream 9

CentOS 8 / CentOS Stream 8 升级 CentOS Stream 9 简明教程

[中文](README.md) | [English](README_EN.md)

---

哦，我的老伙计！你知道吗？`CentOS 8`在2021年12月31日完蛋啦！🎉🎉🎉  
还在用`CentOS 8`吗？为什么不换成`CentOS Stream 8`、`Rocky Linux 8`或者`AlmaLinux`呢？

等等！`CentOS Stream 9`已经发布了？官方源里面居然还有`Nodejs16`和`Golang1.17.5`？还有`kernel5.14`和`glic 2.34`？  

如果你追求新功能和`dnf`包管理器，`CentOS Stream 9`可能是你第二好的选择！（第一依旧是`Fedora`）

可是我的VPS服务商不提供`CentOS Stream 9`的镜像，甚至也不提供`CentOS Stream 8`的镜像，我只能用过时的`CentOS 8`的镜像，这岂不是很糟糕？  

别担心，通过这篇文章提供的方法，您也能在`CentOS 8`上升级到`CentOS Stream 9`，保留所有数据，并且不用重装系统！

## 食用指南

**Warning**：升级大版本有可能会导致软件甚至系统无法正常运行，请谨慎操作！  
**Tips**: 开始操作前请您阅读全文。遇到问题您可以开`issue`，提交更好的解决方案请提交`pull request`。

### 准备工作

使用您熟悉的备份工具备份您的数据，如果您的服务商支持快照功能，强烈建议您创建快照后再进行操作。

###  从`CentOS 8`升级到`CentOS Stream 8`

`CentOS 8`生命周期已结束，您可以通过以下方法升级到`CentOS Stream 8`：

切换到`vault`源，这里使用清华源做演示，您可以更换为其他源。

``` sh

minorver=8.5.2111
sudo sed -e "s|^mirrorlist=|#mirrorlist=|g" \
         -e "s|^#baseurl=http://mirror.centos.org/\$contentdir/\$releasever|baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-vault/$minorver|g" \
         -i.bak \
         /etc/yum.repos.d/CentOS-*.repo

```

更新`CentOS Stream 8`

``` sh

sudo dnf install \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-8-4.el8.noarch.rpm \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-stream-release-8.6-1.el8.noarch.rpm \
    http://mirror.centos.org/centos/8-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-4.el8.noarch.rpm \
    -y

sudo dnf distro-sync --allowerasing -y

```

### 从`CentOS Stream 8`升级到`CentOS Stream 9`

#### 1. 准备RPMs

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
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-release-9.0-22.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-stream-repos-9.0-22.el9.noarch.rpm
wget http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/Packages/centos-gpg-keys-9.0-22.el9.noarch.rpm

cd 

``` 

你可以在`scripts`目录下找到`cs9rpmdownload.sh`，运行它，它会执行上述指令，自动下载所有的RPMs。

#### 2. 移除非必要RPM包和旧内核

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

你可以在`scripts`目录下找到`removekernel.sh`，运行它，它会执行上述指令，自动移除非必要RPM包和旧内核。

#### 3. 升级`CentOS Stream 9`

``` sh 

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

``` 

你可以在`scripts`目录下找到`cs8to9.sh`，运行它，它会执行上述指令，自动升级`CentOS Stream 9`。

上述指令完成后，末行输出应为`CentOS Stream release 9`。

#### 4. 安装新内核

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

你可以在`scripts`目录下找到`installkernel.sh`，运行它，它会执行上述指令，自动安装新内核。

#### 5. 重启系统

检查内核是否安装成功，如果安装成功，请重启系统。

``` sh

dnf list --installed | grep -i "kernel"

sudo reboot

```

重启后，检查内核版本

``` sh

uname -a

``` 

内核版本应为`5.14`

#### 5. 重建rescue镜像

``` sh

echo "Rebuilding rescue image..."
sudo dnf reinstall dracut -y
mkdir -p ~/cs8to9/backup
sudo mv /boot/vmlinuz-0-rescue-* ~/cs8to9/backup
sudo mv /boot/initramfs-0-rescue-*.img ~/cs8to9/backup
sudo /usr/lib/kernel/install.d/51-dracut-rescue.install add $(uname -r) "" /lib/modules/$(uname -r)/vmlinuz

```

你可以在`scripts`目录下找到`rebuildrescue.sh`，运行它，它会执行上述指令，自动重建rescue镜像。

#### 6. （可选）重新安装所有RPM包

``` sh

cd ~/cs8to9/empty
sudo dnf reinstall -y *

```

享受你的新系统！

## License

[![](https://i.creativecommons.org/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)  
OhMyStream9 由 [Ink33](https://github.com/Ink-33) 采用 [知识共享 署名-相同方式共享 4.0 国际 许可协议](http://creativecommons.org/licenses/by-sa/4.0/)进行许可。  

OhMyStream9 by [Ink33](https://github.com/Ink-33) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License.](http://creativecommons.org/licenses/by-sa/4.0/)

### 鸣谢

感谢以下开发者对 OhMyStream9 作出的贡献：

<a href="https://github.com/nonebot/nonebot2/graphs/contributors">
<a href="https://github.com/Ink-33/OhMyStream9/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Ink-33/OhMyStream9" />
</a>
