FROM user:latest

USER root
RUN . ddash; daft faketime libasound2
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1
RUN echo "$LD_PRELOAD">> /etc/ld.so.preload
COPY /lib/eureqa/eureqa_1_24_0_X11_x86-64/ /usr/local/bin/eureqa/

USER nouser

ENTRYPOINT ["dbus-launch"]
CMD ["/usr/local/bin/eureqa/eureqa.sh"]
