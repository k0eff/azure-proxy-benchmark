#!/bin/bash
set -x
echo ${password} | sudo -S -u root -v
# sudo chmod 777 /etc/hosts
# sudo echo 127.0.0.1 ${vmName} >> /etc/hosts // debian fix
# sudo chmod 744 /etc/hosts
# sudo chmod 777 /etc/apt/sources.list
# sudo cat <<EOF >> /etc/apt/sources.list
# deb http://deb.debian.org/debian testing main
# EOF
# sudo chmod 744 /etc/apt/sources.list
sudo apt install software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt update
export DEBIAN_FRONTEND=noninteractive
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
#sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade
sudo apt install -y nginx git wget gcc python3 vim curl autoconf automake cmake curl libtool make ninja-build patch python3-pip unzip virtualenv
sudo ln -s /usr/bin/gcc-9 /usr/bin/gcc
sudo systemctl restart nginx

# Hey setup
mkdir benchmark
cd benchmark/
wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod 744 ./hey

# Envoy Nighthawk setup
wget -O bazel https://github.com/bazelbuild/bazel/releases/download/5.1.1/bazel-5.1.1-linux-x86_64
sudo chmod a+x ./bazel
sudo mv ./bazel /usr/bin/bazel
git clone https://github.com/envoyproxy/nighthawk
cd nighthawk/
bazel build -c opt //:nighthawk

echo "Provisioning Finished!"

