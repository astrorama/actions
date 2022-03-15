#!/bin/bash
set -ex

# Platform-specific configuration
source /etc/os-release

# Figure out the python version to use
PYTHON="python3"
NUMPY="python3-numpy"
if [ "$ID" == "fedora" ] && [ "$VERSION_ID" -lt 30 ]; then
  PYTHON="python"
  NUMPY="python2-numpy"
elif [ "$ID" == "centos" ] && [ "$VERSION_ID" -lt 8 ]; then
  PYTHON="python"
  NUMPY="python2-numpy"
fi

# From the CMakeLists.txt, retrieve the list of dependencies
cmake_deps=$(grep -oP '^elements_project\(\S+\s+\S+ USE \K(\S+ \S+)*(?=\))' CMakeLists.txt)
rpm_dev_deps=$(echo ${cmake_deps} | awk '{for(i=1;i<NF;i+=2){print $i "-devel-" $(i+1)}}')
yum install -y ${rpm_dev_deps}

# Common dependencies
yum install -y cmake make gcc-c++ rpm-build

# Install dependency list
sed -e "s/\$PYTHON/$PYTHON/" "$1" | sed -e "s/\$NUMPY/$NUMPY/" | xargs yum install -y
