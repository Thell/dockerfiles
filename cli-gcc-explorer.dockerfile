# GCC Explorer
FROM cli

RUN git clone https://github.com/mattgodbolt/gcc-explorer.git
WORKDIR gcc-explorer
RUN make node_modules

EXPOSE 10240
CMD ["make", "run"]
