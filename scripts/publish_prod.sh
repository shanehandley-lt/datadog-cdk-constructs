#!/bin/bash

# Unless explicitly stated otherwise all files in this repository are licensed
# under the Apache License Version 2.0.
# This product includes software developed at Datadog (https://www.datadoghq.com/).
# Copyright 2021 Datadog, Inc.

set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ $BRANCH != "main" ]; then
    echo "Not on main, aborting"
    exit 1
fi

#Read the current version
CURRENT_VERSION=$(node -pe "require('./package.json').version")

#Read the desired version
if [ -z "$1" ]; then
    echo "Must specify a desired version number"
    exit 1
elif [[ ! $1 =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "Must use a semantic version, e.g., 3.1.4"
    exit 1
else
    VERSION=$1
fi

#Confirm to proceed
read -p "About to bump the version from ${CURRENT_VERSION} to ${VERSION}, and publish. Continue (y/n)?" CONT
if ["$CONT" != "y"]; then
    echo "Exiting"
    exit 1
fi

yarn login

echo "Bumping the version number and committing the changes"
yarn version --new-version "$VERSION"

echo 'Publishing to Node'
yarn test
yarn build
yarn publish --new-version "$VERSION"

echo 'Pushing updates to github'
git push origin main
git push origin "refs/tags/v$VERSION"
echo 'Please add release notes in GitHub!'
