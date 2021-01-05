#!/usr/bin/env bash

PROGNAME=$(basename $0)
SCRIPT_PATH="$(cd "$(dirname "$0")"; pwd -P)"
CURRENT_DIR="$(pwd)"
ROOT_DIR="${SCRIPT_PATH}/.."

DEST="${ROOT_DIR}/layouts/partials"

rm -f "${DEST}/git-commit-short.html" "${DEST}/git-branch-name.html" "${DEST}/git-repo-url.html" \
    "${DEST}/theme-git-commit-short.html" "${DEST}/theme-git-repo-url.html" \
    "${DEST}/hugo-version.html"
