# PBSI Development Support
FROM rstudio

USER root

RUN . ddash; eval "$pstime"; \
daft\
#apt-get -y install\
 libcairo2-dev\
 libfreetype6-dev\
 libgif-dev\
 libjpeg8-dev\
 libpango1.0-dev\
 librsvg2-bin\
 r-cran-rgl\
 r-cran-xml

RUN \
# R installs
set -e; \
export MAKEFLAGS='--jobs --silent'; \
echo 'install.packages( c(\
 "data.table",\
 "ggplot2",\
 "ggvis",\
 "gmp",\
 "gridSVG",\
 "rbenchmark",\
 "RcppArmadillo",\
 "Rmpfr"\
  ), repos=list( CRAN="https://cran.rstudio.com"), quiet=TRUE )' | r

RUN DEBIAN_FRONTEND=noninteractive apt-out apt-get -qq build-dep r-cran-rgl

USER thell

# They got my patch in, so try it out..
# RUN echo "require(devtools); install_github('Thell/gridSVG')" | sudo r

RUN \
# Vega 2 doesn't accept the json ggvis generates when trying to use vg2XXX
# commands so vega needs to be pinned. nodejs 4.x wont install vega@1.5.4...
mkdir .local/lib/nvm; \
ln -s .local/lib/nvm .nvm; \
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash; \
. .nvm/nvm.sh; \
sudo bash -c ". .nvm/nvm.sh;\
 nvm install 0.12.7;\
 nvm alias default 0.12.7;\
 npm install --silent vega@1.5.4 >v /dev/null;"; \
ln -s -t ~/.local/bin ~/node_modules/vega/bin/*

RUN \
git clone https://github.com/sputnick-dev/saxon-lint.git ~/.local/lib/saxon-lint; \
chmod +x ~/.local/lib/saxon-lint/saxon-lint.pl; \
sudo ln -s ~/.local/lib/saxon-lint/saxon-lint.pl /usr/local/bin/saxon-lint;

ENTRYPOINT ["/bin/bash", "-l", "-i", "-c"]
CMD ["rstudio Projects/PBSICanonicalTest/PBSICanonicalTest.Rproj"]
