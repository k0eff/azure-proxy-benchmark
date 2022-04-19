#!/bin/bash
set -x
echo ${password} | sudo -S -u root -v

sudo apt update

sudo apt-get install -y autoconf automake cmake curl libtool make ninja-build patch python3-pip unzip virtualenv clang



# Install bazelisk instead of bazel
sudo wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-$([ $(uname -m) = "aarch64" ] && echo "arm64" || echo "amd64")
sudo chmod +x /usr/local/bin/bazel

# Hey setup
mkdir benchmark
cd benchmark/
wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod 744 ./hey

# Envoy Nighthawk setup
git clone https://github.com/envoyproxy/nighthawk
cd nighthawk/
git checkout ba3b5d0bcc57c334f34e1c323c6bb564781caa60
echo "build --config=clang" >> user.bazelrc

# bazel build -c opt //:nighthawk # Run it manually
# ci/do_ci.sh build

echo "Provisioning Finished!"

