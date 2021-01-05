#!/usr/bin/env bash

#########################################
# Script written based on answer here:  #
# https://serverfault.com/a/917253      #
#########################################

# url="git://github.com/some-user/my-repo.git"
# url="https://github.com/some-user/my-repo.git"
url="$1"

re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"

if [[ $url =~ $re ]]; then
    protocol=${BASH_REMATCH[1]}
    separator=${BASH_REMATCH[2]}
    hostname=${BASH_REMATCH[3]}
    user=${BASH_REMATCH[4]}
    repo=${BASH_REMATCH[5]}
    echo "https://${hostname}/${user}/${repo}"
fi
