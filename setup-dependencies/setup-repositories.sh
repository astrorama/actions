#!/bin/bash
set -ex

# Platform-specific configuration
source /etc/os-release

# On CentOS, install EPEL
if [ "$ID" == "centos" ]; then
  yum install -y epel-release
  # Need powertools on CentOS8
  if [ "$VERSION_ID" -ge 8 ]; then
    sed -i "s/enabled=0/enabled=1/" /etc/yum.repos.d/CentOS*-PowerTools.repo
  fi
fi

# Astrorama repository
cat >/etc/yum.repos.d/astrorama.repo <<EOF
[Artifactory-Astrorama]
name=Artifactory-Astrorama
baseurl=https://astrorama.jfrog.io/artifactory/rpm/stable/${ID}/\$releasever/\$basearch
enabled=1
gpgcheck=0
EOF

# Develop repository if not building for master
if [ "${GITHUB_REF#refs/heads/}" != "master" ]; then
  cat >>/etc/yum.repos.d/astrorama.repo <<EOF
[Artifactory-Astrorama-Develop]
name=Artifactory-Astrorama-Develop
baseurl=https://astrorama.jfrog.io/artifactory/rpm/develop/${ID}/\$releasever/\$basearch
enabled=1
gpgcheck=0
EOF
fi
