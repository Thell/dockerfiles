# CLI tools via terminator and standard firefox browser
FROM cli:latest

# BUILD_CMD: docker build ${args} -f 20-gui.dockerfile -t gui:latest ./no-context

# Apt installs
RUN . ddash; eval "$pstime"; \
# GUI support packages with recommends...
daft -r\
 dbus-x11\
 libasound2-plugins\
 libcanberra-gtk0\
 libcanberra-gtk3-0\
 libcanberra-pulse\
 libgstreamer0.10-0\
 gstreamer0.10-alsa\
 gstreamer0.10-pulseaudio\
 libgstreamer-plugins-base0.10-0\
 libqt5webkit5\
 pulseaudio\
 terminator\
 xvfb

# Silence terminator startup message
# mount host's ${HOME}/.config/terminator to personalize.
RUN \
mkdir /root/.config/terminator; \
touch /root/.config/terminator/config

ENV \
NO_AT_BRIDGE=1 \
QT_X11_NO_MITSHM=1

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["terminator"]
