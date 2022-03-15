#!/bin/bash
set -ex

BUILD_DIR="$1"
RELEASE="$2"

# Environment
export VERBOSE=1
export CTEST_OUTPUT_ON_FAILURE=1
export BRANCH="${GITHUB_REF#refs/heads/}"

# Platform-specific configuration
source /etc/os-release

# Common flags
CMAKEFLAGS="-DINSTALL_DOC=OFF -DUSE_SPHINX_APIDOC=OFF -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_TESTS=OFF -DRPM_NO_CHECK=OFF"
if [[ "${BRANCH}" != "master" && -z "${RELEASE}" ]]; then
  CMAKEFLAGS="${CMAKEFLAGS} -DCPACK_PACKAGE_RELEASE=dev"
fi

if [[ ("$ID" == "fedora" && "$VERSION_ID" -ge 30) || ("$ID" == "centos" && "$VERSION_ID" -ge 8) ]]; then
  CMAKEFLAGS="${CMAKEFLAGS} -DPYTHON_EXPLICIT_VERSION=3"
fi

if [[ ! -z "${RELEASE}" ]]; then
  CMAKEFLAGSS="${CMAKEFLAGS} -DCPACK_PACKAGE_RELEASE=${RELEASE}"
fi

# Build
SRCDIR="$(pwd)"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_TESTS=OFF -DRPM_NO_CHECK=OFF $CMAKEFLAGS "${SRCDIR}"
make rpm
