# RStudio Preview Base Setup
FROM thell:latest

# Minimal required to use all of the base features of RStudio Desktop.
# Uses the latest preview release, along with the most recent pandoc,
# mathjax, mathjax third party extensions, ccache for c++ work, and
# the testthat and microbenchmark packages.

# The Renviron is setup to use the new pandoc and mathjax.

USER root

# Apt repos setup
RUN . ddash; eval $pstime; \
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9; \
apt-add-repository "deb http://cran.rstudio.com/bin/linux/ubuntu wily/"; \
# r-cran- binaries
apt-add-repository -ys ppa:marutter/c2d4u

RUN . ddash; eval "$pstime"; apt-out apt-get update

# Apt installs
RUN . ddash; eval "$pstime"; \
# Without recommends...
daft\
# Feature support
 default-jdk\
 default-jre-headless\
 firefox\
 libreoffice-base\
 libreoffice-java-common\
 libreoffice-writer\
 littler\
 lmodern\
 r-base\
 r-base-dev\
 r-recommended\
 subversion\
 texinfo\
 texlive-base\
 texlive-extra-utils\
 texlive-fonts-extra\
 texlive-fonts-recommended\
 texlive-generic-recommended\
 texlive-latex-base\
 texlive-latex-extra\
 texlive-latex-recommended

RUN . ddash; eval "$pstime"; \
# With recommends...
daft -r\
#apt-get -y install\
# Dev tools
 ccache\
 clang-format-3.7\
# R support
 libcurl4-openssl-dev\
 libssh2-1-dev\
 libssl-dev\
 libxml2-dev\
 r-cran-base64enc\
 r-cran-rcurl\
 r-cran-rjsonio\
 r-cran-rmarkdown; \

ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r; \
ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r; \
ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r; \
ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r

RUN \
# R installs
set -e; \
export MAKEFLAGS='--jobs --silent'; \
echo 'install.packages( c(\
 "devtools",\
 "docopt",\
 "microbenchmark"\
 "packrat",\
 "PKI",\
 "Rcpp",\
 "shiny"\
  ), repos=list( CRAN="https://cran.rstudio.com"), quiet=TRUE )' | r; \
echo "devtools::install_github('hadley/testthat')" | r; \
echo "devtools::install_github('hadley/devtools')" | r


# Non-Apt App Downloads via Aria2
RUN . ddash && eval "$pstime" \
&& export DEBIAN_FRONTEND=noninteractive \

&& URL=https://www.rstudio.com/products/rstudio/download/preview/ \
&& EXPR='a[href$="amd64.deb"]:not([href*="server"]) attr{href}' \
&& curl -sS -L $URL | pup "${EXPR}" > input.txt \
&& printf "\tout=rstudio.deb\n" >> input.txt \

&& URL=https://api.github.com/repos/jgm/pandoc/releases \
&& EXPR='.[]|.assets[]|select(.name|endswith("-amd64.deb"))|.browser_download_url' \
&& curl -sS -L $URL | jq -r "${EXPR}" | head -n 1 >> input.txt \
&& printf "\tout=pandoc.deb\n" >> input.txt \

&& URL=https://api.github.com/repos/MathJax/MathJax/releases/latest \
&& curl -sS -L $URL | jq -r '.tarball_url' >> input.txt \
&& printf "\tout=mathjax.tar.gz\n" >> input.txt \

&& URL=https://github.com/mathjax/MathJax-third-party-extensions/archive/master.tar.gz \
&& printf "${URL}\n\tout=mathjax-contrib.tar.gz\n" >> input.txt \

&& cat input.txt \
&& aria2c -q -x 4 -i input.txt \

&& gdebi -n ./pandoc.deb \
&& gdebi -n ./rstudio.deb \
&& ln -s /usr/lib/rstudio/bin/rstudio /usr/local/bin/rstudio \

&& mkdir -p /usr/local/lib/mathjax/contrib \
&& tar -C /usr/local/lib/mathjax/ --strip-components 1 -zxf mathjax.tar.gz \
&& tar -C /usr/local/lib/mathjax/contrib --strip-components 1 -zxf mathjax-contrib.tar.gz \

&& rm input.txt rstudio.deb pandoc.deb mathjax.tar.gz mathjax-contrib.tar.gz \

&& PKG=$(find /usr/lib/rstudio/R/packages/rsconnect*.tar.gz ) \
&& echo "install.packages( '${PKG}', repos=NULL, quiet=TRUE )" | r \
&& echo 'update.packages(lib.loc = "/usr/lib/R/site-library", \
	   repo=list( CRAN="https://cran.rstudio.com"), ask=FALSE, quiet=TRUE )' | r

USER thell
RUN \
set -e;\
# Use Renviron to tell RStdudio to use local Pandoc and MathJax.
mkdir -p .config/R .local/lib/R/library; \
ln -s .config/R .R; \

echo "R_LIBS_USER=$HOME/.local/lib/R/library" > ~/.config/R/Renviron; \
echo "RSTUDIO_PANDOC=/usr/bin" >> ~/.config/R/Renviron; \
echo "MAKEFLAGS='--jobs'" >> ~/.config/R/Renviron; \
echo "RMARKDOWN_MATHJAX_PATH=/usr/local/lib/mathjax\n" >> ~/.config/R/Renviron; \

# Tell RStudio to use terminator
mkdir -p .config/rstudio-desktop/monitored/user-settings; \
ln -s .config/rstudio-desktop .rstudio-desktop; \

echo "vcsTerminalPath=\"/usr/bin/terminator\"" >> \
  .rstudio-desktop/monitored/user-settings/user-settings

ENV \
R_ENVIRON_USER=~/.config/R/Renviron \
R_PROFILE_USER=~/.config/R/Rprofile


ENTRYPOINT ["/bin/bash", "-l", "-i", "-c"]
CMD ["rstudio"]
