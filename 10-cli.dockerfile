# Common CLI tools
FROM apt:latest

# BUILD_CMD: docker build ${args} -f 10-cli.dockerfile -t cli:latest ./no-context

# Apt repos setup
RUN \
apt-add-repository -ys multiverse; \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 68576280; \
apt-add-repository -s "deb https://deb.nodesource.com/node_4.x xenial main"

RUN . ddash; eval "$pstime"; apt-out apt-get update

# Apt installs
RUN . ddash; eval "$pstime"; \
# Without recommends...
daft\
# CLI tools
 bash-completion\
 curl\
 gdebi-core\
 libxml2-utils\
 less\
 tree\
 unzip\
 vim\
 wget\
# Dev tools
 build-essential\
 libmpfrc++-dev\
 nodejs; \

# With recommends...
daft -r\
 git

# Non-Apt Installs
RUN . ddash; eval "$pstime";\
# Direct
URL=https://api.github.com/repos/EricChiang/pup/releases/latest; \
URL=$(curl -sS ${URL} |\
 jq -r '.assets[]|select(.name|contains("linux_amd64"))|.browser_download_url'); \
wget -q ${URL} -O pup_linux_amd64.zip; \
unzip -qq pup_linux_amd64.zip -d /usr/local/bin/; \
rm pup_linux_amd64.zip

# It seems the 1.19.0-1build1 version of aria2 has issues with https
# so we'll use the ubuntu yakkety build for now.
RUN . ddash; eval "$pstime";\
URL=http://mirrors.kernel.org/ubuntu/pool/universe/a/aria2/aria2_1.25.0-1_amd64.deb; \
wget -q ${URL}; \
gdebi -n aria2_1.25.0-1_amd64.deb; \
rm aria2_1.25.0-1_amd64.deb

CMD ["/bin/bash", "-l"]
