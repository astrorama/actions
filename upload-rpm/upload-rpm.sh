#!/bin/bash
set -ex

export SCRIPT_DIR="$( dirname -- "${BASH_SOURCE[0]}" )"

# System
source /etc/os-release

OS_TYPE=${ID}
OS_ARCH=$(uname -m)

if [[ $OS_TYPE == "centos" ]]; then
  OS_VERSION=${VERSION_ID}
else
  OS_VERSION=$(python3 -c 'import dnf; db = dnf.dnf.Base(); print(db.conf.releasever)')
  CREATEREPO_ARGS="--checksum=md5"
fi

# Helper to copy the artifacts and update the repo
copy_artifacts() {
  sshpass -e ssh -F "${SCRIPT_DIR}/ssh_config" \
    "mkdir -p /srv/repository/www/html/euclid/${1}"
  sshpass -e scp -F "${SCRIPT_DIR}/ssh_config" "${@:2}" \
    "${REPOSITORY_USER}@repo01.astro.unige.ch:/srv/repository/www/html/euclid/${1}"
  sshpass -e ssh -F "${SCRIPT_DIR}/ssh_config" \
    "${REPOSITORY_USER}@repo01.astro.unige.ch" \
    "cd '/srv/repository/www/html/euclid/${1}' && createrepo ${CREATEREPO_ARGS} --update . && repoview ."
}

yum install -y sshpass openssh-clients
export SSHPASS="${REPOSITORY_PASSWORD}"

umask 077
cat > "${SCRIPT_DIR}/key" <<EOF
${REPOSITORY_KEY}
EOF


if [ -n "${GITHUB_HEAD_REF}" ]; then
  REPO="${GITHUB_HEAD_REF#refs/heads/}"
elif [ -n "${GITHUB_REF_TYPE}" == "tag" ]; then
  REPO=""
else
  BRANCH="${GITHUB_REF#refs/heads/}"
  if [ "$BRANCH" == "master" ]; then
    REPO="stable"
  else
    REPO="${BRANCH}"
  fi
fi

# RPM
copy_artifacts "/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/" $(ls -I "*debug*" "$1"/*.rpm)

# Debug
copy_artifacts "/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/debug/" "$1"/*debug*.rpm

# Source RPM
copy_artifacts "/${REPO}/${OS_TYPE}/${OS_VERSION}/SRPMS/" "$2"/*.rpm

rm "${SCRIPT_DIR}/key"

