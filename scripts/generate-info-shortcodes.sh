#!/usr/bin/env bash

PROGNAME=$(basename $0)
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
CURRENT_DIR="$(pwd)"
ROOT_DIR="${SCRIPT_PATH}/.."

DEST="${ROOT_DIR}/layouts/partials"

# git commit short
git rev-parse --short HEAD | tr -d '\n'  > "${DEST}/git-commit-short.html"
# git branch name
git rev-parse --abbrev-ref HEAD | tr -d '\n' > "${DEST}/git-branch-name.html"
# git commit url
git config --get remote.origin.url | xargs "${SCRIPT_PATH}/get-url-from-remote.sh" | tr -d '\n' > "${DEST}/git-repo-url.html"

# theme git commit short
echo $(cd themes/etch-greg; git rev-parse --short HEAD) | tr -d '\n' > "${DEST}/theme-git-commit-short.html"
# theme repo url
echo $(cd themes/etch-greg; git config --get remote.origin.url | xargs "${SCRIPT_PATH}/get-url-from-remote.sh") | tr -d '\n' > "${DEST}/theme-git-repo-url.html"

# hugo version
hugo version | sed 's|^.*\(v[0-9]*\.[0-9]*\.[0-9]*\).*$|\1|' | tr -d '\n' > "${DEST}/hugo-version.html"
