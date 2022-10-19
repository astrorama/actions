#!/bin/bash
set -ex

# Platform-specific configuration
source /etc/os-release
VERSION_ID="${VERSION_ID%%.*}"

# Enable epel on centos and rocky
if [[ "$ID" == "centos" || "$ID" == "rocky" ]]; then
  yum install -y epel-release
fi

# In centos7, yum passes urlgrabber user_agent, which is forbidden by mod_security in repository.astro.unige.ch
if [[ "$ID" == "centos" && "$VERSION_ID" -eq 7 ]]; then
  sed -i "s/'user_agent': .*/'user_agent': 'yum-centos7',/g" /usr/lib/python2.7/site-packages/yum/yumRepo.py
fi

# On rockylinux, enable crb repository and
if [[ "$ID" == "rocky" ]]; then
  crb enable
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
if [[ "${GITHUB_REF#refs/heads/}" != "master" && "${GITHUB_BASE_REF#refs/heads/}" != "master" ]]; then
  cat >>/etc/yum.repos.d/astrorama.repo <<EOF
[AstroUnigeEuclidDevel]
name=astro.unige.ch Euclid Devel
baseurl=http://repository.astro.unige.ch/euclid/devel/develop/${ID}/\$releasever/\$basearch
enabled=1
gpgcheck=0
EOF
fi
