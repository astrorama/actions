#!/bin/bash
set -ex

copy_artifacts() {
  scp -o 'ProxyJump login02.astro.unige.ch' "$1" "repo01.astro.unige.ch:${2}"
  ssh -J "login02.astro.unige.ch" "repo01.astro.unige.ch" "cd '${2}' && createrepo --update . && repoview ."
}

sshpass -d6 "${REPOSITORY_USER}@repo01.astro.unige.ch" 6<<< "${REPOSITORY_PASSWORD}"
sshpass -d6 "${REPOSITORY_USER}@login02.astro.unige.ch" 6<<< "${REPOSITORY_PASSWORD}"



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

# RPM
copy_artifacts "$1/*.rpm" "/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/"

# Debug
copy_artifacts "$1/*debug*.rpm" "/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/debug/"

# Source RPM
copy_artifacts "$1/*.rpm" "/${REPO}/${OS_TYPE}/${OS_VERSION}/SRPMS/"

