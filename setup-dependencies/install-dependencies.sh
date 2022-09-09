#!/bin/bash
set -ex

# Platform-specific configuration
source /etc/os-release

# Figure out the python version to use
export PYTHON="python3"
export NUMPY="python3-numpy"
export BOOST="boost"
if [ "$ID" == "fedora" ] && [ "$VERSION_ID" -lt 30 ]; then
  PYTHON="python"
  NUMPY="python2-numpy"
elif [ "$ID" == "centos" ] && [ "$VERSION_ID" -lt 8 ]; then
  PYTHON="python"
  NUMPY="python2-numpy"
  BOOST="boost169"
fi

# From the CMakeLists.txt, retrieve the list of dependencies
cmake_deps=$(grep -oP '^elements_project\(\S+\s+\S+ USE \K(\S+ (\d\.?)+)*' CMakeLists.txt)
rpm_dev_deps=$(echo ${cmake_deps} | awk '{for(i=1;i<NF;i+=2){print $i "-devel-" $(i+1)}}')
rpm_doc_deps=$(echo ${cmake_deps} | awk '{for(i=1;i<NF;i+=2){print $i "-doc-" $(i+1)}}')
yum install -y ${rpm_dev_deps} ${rpm_doc_deps}

# Common dependencies
yum install -y cmake make gcc-c++ rpm-build

# Install dependency list
envsubst < "$1" | xargs yum install -y
