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
 jq -r '.assets[]|select(.name=="pup_linux_amd64.zip")|.browser_download_url'); \
wget -q ${URL}; \
unzip -qq pup_linux_amd64.zip -d /usr/local/bin/; \
rm pup_linux_amd64.zip

CMD ["/bin/bash", "-l"]
