#!/bin/bash

BRANCH="${GITHUB_REF#refs/heads/}"
if [ "$BRANCH" == "master" ]; then
  REPO="stable"
else
  REPO="$BRANCH"
fi

jfrog rt u "$1/*.rpm" "rpm/${REPO}/${OS_TYPE}/${OS_VERSION}/${OS_ARCH}/rpms/"

