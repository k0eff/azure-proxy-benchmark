#!/bin/bash
set -x
echo ${password} | sudo -S -u root -v

sudo apt update
sudo apt install -y apache2-utils

sudo apt-get install -y autoconf automake cmake curl libtool make ninja-build patch python3-pip unzip virtualenv clang 
sudo apt install -y lld clang-12 llvm-12 lld-12 lldb-12
sudo apt install -y clang-{format,tidy,tools}-12 clang-12-doc clang-12-examples
sudo update-alternatives \
  --install /usr/lib/llvm              llvm             /usr/lib/llvm-12  20 \
  --slave   /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-12  \
	--slave   /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-12 \
	--slave   /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-12 \
	--slave   /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-12 \
	--slave   /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-12 \
	--slave   /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-12 \
	--slave   /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-12 \
	--slave   /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-12 \
	--slave   /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-12 \
	--slave   /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-12 \
	--slave   /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-12 \
	--slave   /usr/bin/llvm-mcmarkup     llvm-mcmarkup    /usr/bin/llvm-mcmarkup-12 \
	--slave   /usr/bin/llvm-nm           llvm-nm          /usr/bin/llvm-nm-12 \
	--slave   /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-12 \
	--slave   /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-12 \
	--slave   /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-12 \
	--slave   /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-12 \
	--slave   /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-12 \
	--slave   /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-12 \
	--slave   /usr/bin/llvm-symbolizer   llvm-symbolizer  /usr/bin/llvm-symbolizer-12 \
	--slave   /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-12

sudo update-alternatives \
  --install /usr/bin/clang                 clang                  /usr/bin/clang-12     20 \
  --slave   /usr/bin/clang++               clang++                /usr/bin/clang++-12 \
  --slave   /usr/bin/lld                   lld                    /usr/bin/lld-12 \
  --slave   /usr/bin/clang-format          clang-format           /usr/bin/clang-format-12  \
  --slave   /usr/bin/clang-tidy            clang-tidy             /usr/bin/clang-tidy-12  \
  --slave   /usr/bin/clang-tidy-diff.py    clang-tidy-diff.py     /usr/bin/clang-tidy-diff-12.py \
  --slave   /usr/bin/clang-include-fixer   clang-include-fixer    /usr/bin/clang-include-fixer-12 \
  --slave   /usr/bin/clang-offload-bundler clang-offload-bundler  /usr/bin/clang-offload-bundler-12 \
  --slave   /usr/bin/clangd                clangd                 /usr/bin/clangd-12 \
  --slave   /usr/bin/clang-check           clang-check            /usr/bin/clang-check-12 \
  --slave   /usr/bin/scan-view             scan-view              /usr/bin/scan-view-12 \
  --slave   /usr/bin/clang-apply-replacements clang-apply-replacements /usr/bin/clang-apply-replacements-12 \
  --slave   /usr/bin/clang-query           clang-query            /usr/bin/clang-query-12 \
  --slave   /usr/bin/modularize            modularize             /usr/bin/modularize-12 \
  --slave   /usr/bin/sancov                sancov                 /usr/bin/sancov-12 \
  --slave   /usr/bin/c-index-test          c-index-test           /usr/bin/c-index-test-12 \
  --slave   /usr/bin/clang-reorder-fields  clang-reorder-fields   /usr/bin/clang-reorder-fields-12 \
  --slave   /usr/bin/clang-change-namespace clang-change-namespace  /usr/bin/clang-change-namespace-12 \
  --slave   /usr/bin/clang-import-test     clang-import-test      /usr/bin/clang-import-test-12 \
  --slave   /usr/bin/scan-build            scan-build             /usr/bin/scan-build-12 \
  --slave   /usr/bin/scan-build-py         scan-build-py          /usr/bin/scan-build-py-12 \
  --slave   /usr/bin/clang-cl              clang-cl               /usr/bin/clang-cl-12 \
  --slave   /usr/bin/clang-rename          clang-rename           /usr/bin/clang-rename-12 \
  --slave   /usr/bin/find-all-symbols      find-all-symbols       /usr/bin/find-all-symbols-12 \
  --slave   /usr/bin/lldb                  lldb                   /usr/bin/lldb-12 \
  --slave   /usr/bin/lldb-server           lldb-server            /usr/bin/lldb-server-12

clang -v


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

