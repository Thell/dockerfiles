# Dockerfile Snippets

## Pandoc local build

````{bash}
# install haskell-platform then ...
cabal update; \
cabal install -j pandoc pandoc-citeproc; \
ln -s -t ~/.local/bin ~/.cabal/bin/*; \
mkdir -p .local/lib/pandoc/templates; \
ln -s .local/lib/pandoc .pandoc
````

## Latest JQ

````{bash}
RUN \
URL=https://api.github.com/repos/stedolan/jq/releases/latest; \
curl -o jq -L \
  $(curl -sS ${URL} | jq -r '.assets|.[]|select(.name == "jq-linux64")|.browser_download_url'); \

chmod +x jq; \
mv -f jq /usr/bin/jq;
````

## R ccache setup

````
echo "CC=ccache gcc\nCXX=ccache g++\nCFLAGS+=-std=c11\nCXXFLAGS+=-std=c++11\n" > ~/.config/R/Makevars; \
````

## GNU Parallel

Install and ...

````{bash}
echo "--no-notice" > /etc/parallel/config; \
````

## Node Repo and key

````
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68576280
RUN apt-add-repository -s "deb https://deb.nodesource.com/node_0.12 vivid main"
````

## apt-fast

````
RUN \
echo "apt-fast apt-fast/maxdownloads string 5" | debconf-set-selections; \
echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections; \
apt-get -qq --no-install-recommends install	apt-fast
````

## apt-fast aria2 config

````
RUN \
# apt-fast aria2 command setup
sed -i'' "/^_DOWNLOADER=/ s/-m0/-m0 \
 --quiet \
 --console-log-level=error \
 --show-console-readout=false \
 --summary-interval=10 \
 --enable-rpc \
 --on-download-stop=apt-fast-progress/" /etc/apt-fast.conf
````

## C++ compiler repos

````
# GCC repository
apt-add-repository -ys ppa:ubuntu-toolchain-r/test; \

# LLVM repository
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AF4F7421; \
apt-add-repository -s "deb http://llvm.org/apt/vivid/ llvm-toolchain-vivid-3.7 main"
````

then update && upgrade and install

````
  build-essential \
  ccache \
  clang-3.7 \
  clang-modernize-3.7 \
  clang-format-3.7 \
  gdb \
  lldb-3.7 \
````


