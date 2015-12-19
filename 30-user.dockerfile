# User definition
FROM gui:latest

# User Setup
ARG USER="nouser"
ARG USERNAME="No User"
ARG USEREMAIL="nouser@example.com"
ARG DOSUDO="false"

RUN set -e;\
adduser --disabled-password --gecos '' ${USER}; \
echo "${USER}:${USER}" | chpasswd; \
usermod -a -G video ${USER}; \
usermod -a -G audio ${USER}; \
chown -R ${USER} /home/${USER}; \

[ "${DOSUDO}" = "true" ] || exit 0; \
. ddash; daft sudo; \
adduser ${USER} sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USER
WORKDIR /home/$USER

RUN \
set -e;\
xdg-user-dirs-update; \
mkdir -p .local/bin .local/opt .local/src .local/lib ./local/tmp; \
ln -s .local/bin ./bin; \
ln -s .local/tmp ./tmp; \

# Stop terminator config complaint.
mkdir .config/terminator; \
touch .config/terminator/config; \

# Git setup
git config --global user.name "$USERNAME"; \
git config --global user.email $USEREMAIL; \
git config --global alias.last 'log -1 HEAD'; \
git config --global alias.unstage 'reset HEAD --'; \
git config --global alias.co checkout; \
git config --global alias.br branch; \
git config --global alias.ci commit; \
git config --global alias.st status


ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["terminator"]
