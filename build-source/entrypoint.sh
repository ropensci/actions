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

# Get the package
REPO=$(basename $1)
git clone --depth 1 "$1" "${REPO}"
COMMIT_TIMESTAMP="$(git --git-dir=${REPO}/.git log -1 --format=%ct)"
DISTRO="$(lsb_release -sc)"
PACKAGE=$(grep '^Package:' "${REPO}/DESCRIPTION" | sed 's/^Package://')
VERSION=$(grep '^Version:' "${REPO}/DESCRIPTION" | sed 's/^Version://')
PACKAGE=$(echo -n "${PACKAGE//[[:space:]]/}")
VERSION=$(echo -n "${VERSION//[[:space:]]/}")
PKG_VERSION="${PACKAGE}_${VERSION}"
SOURCEPKG="${PKG_VERSION}.tar.gz"
BINARYPKG="${PKG_VERSION}_R_x86_64-pc-linux-gnu.tar.gz"

# Get dependencies
Rscript -e "install.packages('remotes')"
Rscript -e "remotes::install_github('jeroen/makeconf')"
Rscript -e "setwd('$REPO'); install.packages(remotes::local_package_deps(dependencies=TRUE))"

# Build source package. Try vignettes, but build without otherwise.
rm -Rf ${REPO}/.git
R CMD build ${REPO} --no-manual ${BUILD_ARGS} || R CMD build ${REPO} --no-manual --no-build-vignettes ${BUILD_ARGS}

# Confirm that package can be installed on Linux
test -f "$SOURCEPKG"
R CMD INSTALL "$SOURCEPKG"

# Find sysdeps
SYSDEPS=$(Rscript -e "cat(paste(makeconf::dpkg_sysdeps('$PACKAGE'), collapse = ', '))")

# Set output values
echo ::set-output name=DISTRO::$DISTRO
echo ::set-output name=PACKAGE::$PACKAGE
echo ::set-output name=VERSION::$VERSION
echo ::set-output name=SYSDEPS::$SYSDEPS
echo ::set-output name=SOURCEPKG::$SOURCEPKG
echo ::set-output name=COMMIT_TIMESTAMP::$COMMIT_TIMESTAMP
