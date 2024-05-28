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
VERSION_ID="${VERSION_ID%%.}"

# Common flags
#CMAKEFLAGS="-DINSTALL_DOC=ON -DUSE_SPHINX_APIDOC=OFF -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_TESTS=OFF -DRPM_NO_CHECK=OFF"
CMAKEFLAGS="-DINSTALL_DOC=ON -DUSE_SPHINX_APIDOC=OFF -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_TESTS=OFF -DRPM_NO_CHECK=ON"

if [[ ! -z "${RELEASE}" ]]; then
  CMAKEFLAGS="${CMAKEFLAGS} -DCPACK_PACKAGE_RELEASE=${RELEASE}"
elif [[ "${BRANCH}" != "master" && "${GITHUB_REF_TYPE}" != "tag" ]]; then
  CMAKEFLAGS="${CMAKEFLAGS} -DCPACK_PACKAGE_RELEASE=dev"
fi

if [[ ("$ID" == "fedora" && "$VERSION_ID" -ge 30) || ("$ID" == "centos" && "$VERSION_ID" -ge 8) || ("$ID" == "rocky") ]]; then
  CMAKEFLAGS="${CMAKEFLAGS} -DPYTHON_EXPLICIT_VERSION=3"
fi

# Use boost169 in centos7
if [[ "$ID" == "centos" && "$VERSION_ID" -eq 7 ]]; then
  export BOOST_INCLUDEDIR=/usr/include/boost169/
  export BOOST_LIBRARYDIR=/usr/lib64/boost169/
fi

# Build
SRCDIR="$(pwd)"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"
cmake -DCMAKE_INSTALL_PREFIX=/usr -DINSTALL_TESTS=OFF -DRPM_NO_CHECK=OFF $CMAKEFLAGS "${SRCDIR}"
make rpm
