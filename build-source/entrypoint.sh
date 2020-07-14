#!/bin/bash -l
set -e
echo "Building ${1} in ${PWD}"

# Setup build environment
if [ "${R_LIBS_USER}" ]; then mkdir -p $R_LIBS_USER; fi
if [ "${CRAN}" ]; then echo 'options(repos = c(CRAN = "$(CRAN)"))' > ~/.Rprofile; fi
echo 'options(Ncpus = 2, crayon.enabled = TRUE)' >> ~/.Rprofile
echo 'utils::setRepositories(ind = 1:4)' >> ~/.Rprofile
echo 'options(repos = c(rOpenSci = "https://dev.ropensci.org", getOption("repos")))' >> ~/.Rprofile
echo 'DISPLAY=""' >> ~/.Renviron
echo 'R_BROWSER="echo"' >> ~/.Renviron
echo 'R_PDFVIEWER="echo"' >> ~/.Renviron
echo 'RGL_USE_NULL=TRUE' >> ~/.Renviron
echo '_R_CHECK_FORCE_SUGGESTS_=FALSE' >> ~/.Renviron
echo '_R_CHECK_CRAN_INCOMING_=FALSE' >> ~/.Renviron
echo '_R_CHECK_CRAN_INCOMING_REMOTE_=FALSE' >> ~/.Renviron
echo 'R_COMPILE_AND_INSTALL_PACKAGES=never' >> ~/.Renviron

# Get the package
git clone --depth 1 "$1"
PKG=$(basename $1)
VERSION=$(grep '^Version:' "${PKG}/DESCRIPTION" | sed 's/^Version://')
VERSION=$(echo -n "${VERSION//[[:space:]]/}")
PKG_VERSION="${PKG}_${VERSION}"
PKG_SOURCE="${PKG_VERSION}.tar.gz"
PKG_BINARY="${PKG_VERSION}_R_x86_64-pc-linux-gnu.tar.gz"

# Get dependencies
Rscript -e "install.packages('remotes')"
Rscript -e "setwd('$PKG'); install.packages(remotes::local_package_deps(dependencies=TRUE))"

# Build source package
rm -Rf ${PKG}/.git
R CMD build ${PKG} --no-manual ${BUILD_ARGS}

# Confirm that file exists and exit
test -f "$PKG_SOURCE"
echo ::set-output name=PKG_SOURCE::$PKG_SOURCE
