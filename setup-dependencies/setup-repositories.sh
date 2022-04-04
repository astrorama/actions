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

# Update image
yum update -y

# Astrorama repository
cat >/etc/yum.repos.d/astrorama.repo <<EOF
[AstroUnigeEuclidStable]
name=astro.unige.ch Euclid Stable
baseurl=http://repository.astro.unige.ch/euclid/${ID}/\$releasever/\$basearch
enabled=1
gpgcheck=0
EOF

# Develop repository if not building for master
if [ "${GITHUB_REF#refs/heads/}" != "master" ]; then
  cat >>/etc/yum.repos.d/astrorama.repo <<EOF
[AstroUnigeEuclidDevel]
name=astro.unige.ch Euclid Devel
baseurl=http://repository.astro.unige.ch/euclid/devel/${ID}/\$releasever/\$basearch
enabled=1
gpgcheck=0
EOF
fi
