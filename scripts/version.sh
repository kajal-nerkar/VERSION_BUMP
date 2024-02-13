#!/bin/bash

SCRIPT_DIR=$(dirname $0)
ROOT_PATH=$(realpath $SCRIPT_DIR/..)

helpText="

./scripts/version.sh --<options>
version.sh.sh takes following options

available options:
./scripts/version.sh --bump-version  # Full version bump
./scripts/version.sh --bump-commit   # Short commit bump
"

printHelp() {
  echo "${helpText}"
}

if [ -z "$1" ]; then
  echo "Please give proper option to change the version"
  printHelp
  exit 1
fi

OLD_FULL_VERSION=$(jq -r ".version" $ROOT_PATH/config/version.json) #example version 0.5.1-8f6b7505
REV=$(echo "$OLD_FULL_VERSION" | rev) #reverse the version --> 5057b6f8-1.5.0
VERSION=$(echo "${REV#*.}" | rev)
BUILD=$(echo "$REV" | awk -F[-.] '{print $2}' | rev) #take a build number in between - and .
BUILD=$((BUILD + 1)) #increase the build example 1 to 2
SHORT_COMMIT_HASH=$(echo "$(git rev-parse HEAD)" | cut -c 1-8)
if [[ $1 == "--bump-version" ]]; then
   NEW_FULL_VERSION=$(echo $VERSION.$BUILD-$SHORT_COMMIT_HASH) #new version 0.5.2-90ab305a
elif [[ $1 == "--bump-commit" ]]; then
   OLD_VERSION_BUILD=$(echo "$OLD_FULL_VERSION" | awk -F- '{print $1}')
   NEW_FULL_VERSION=$(echo $OLD_VERSION_BUILD-$SHORT_COMMIT_HASH) #example version 0.5.1-c33fg55d , only short commit hash change for debug build
fi
echo "version increased to $NEW_FULL_VERSION"
contents="$(jq ".version = \"$NEW_FULL_VERSION\"" $ROOT_PATH/config/version.json)"
echo "${contents}" >$ROOT_PATH/config/version.json
