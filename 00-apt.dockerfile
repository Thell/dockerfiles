# Apt tooling setup
FROM ubuntu:16.04

# BUILD_CMD: docker build ${args} -f 00-apt.dockerfile -t apt:latest ./scripts

WORKDIR /root

# Helper scripts
COPY /scripts/ddash /usr/local/bin/ddash
COPY /scripts/apt-fast /usr/local/bin/apt-fast
COPY /scripts/apt-fast.conf /etc/apt-fast.conf
COPY /scripts/apt-fast-progress.sh /usr/local/bin/apt-fast-progress
COPY /scripts/apt-out.sh /usr/local/bin/apt-out

# Environment and Locale Setup
ENV \
container=docker \
TERM=xterm-256color
RUN \
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
&& locale-gen en_US.UTF-8 \
&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV \
LANG=en_US.UTF-8 \
LANGUAGE=en_US.UTF-8 \
LC_ALL=en_US.UTF-8

# Apt tooling setup
RUN . ddash; eval "$pstime";\
apt-out apt-get update; \
DEBIAN_FRONTEND=noninteractive apt-out apt-get -yq install\
 libapt-inst2.0\
 apt-utils; \
# apt-out dpkg -i ./libapt*.deb ./apt*.deb; \
# rm -f ./*.deb; \
daft\
 aria2\
 eatmydata\
 httpie\
 jq; \
daft\
 apt-transport-https\
 dialog\
 software-properties-common\
 xdg-user-dirs

# Upgrade before building any further.
RUN . ddash; eval "$pstime"; \
apt-out apt-get update; \
apt-get -yq dist-upgrade

RUN xdg-user-dirs-update

CMD ["/bin/bash", "-l"]
