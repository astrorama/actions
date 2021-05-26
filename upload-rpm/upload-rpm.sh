#!/bin/bash
set -ex

BRANCH="${GITHUB_REF#refs/heads/}"
if [ "$BRANCH" == "master" ]; then
  REPO="stable"
else
  REPO="$BRANCH"
fi

source /etc/os-release

OS_TYPE=${ID}
OS_ARCH=$(uname -m)

if [[ $OS_TYPE == "centos" ]]; then
  OS_VERSION=${VERSION_ID}
else
  OS_VERSION=$(python3 -c 'import dnf; db = dnf.dnf.Base(); print(db.conf.releasever)')
fi

jfrog rt u "$1/*.rpm" "rpm/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/rpms/"

