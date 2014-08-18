#!/bin/bash

REPOS="aii CAF CCM cdp-listend configuration-modules-core configuration-modules-grid LC maven-tools ncm-cdispd ncm-lib-blockdevices ncm-ncd ncm-query pkgtree protocols quattor-remote-configure release rpmt-py scdb scdb-ant-utils spma template-library-core template-library-examples template-library-grid template-library-os template-library-standard"
RELEASE=""

if [[ -n $1 && -n $2 ]]; then
    PREV=$1
    RELEASE=$2
else
    echo "ERROR: Release versions not provided"
    echo "    Based on the date, you should probably be working on $(date +%y.%m)"
    echo "USAGE: $0 PREVIOUS_RELEASE THIS_RELEASE"
    exit 3
fi

details=""
mkdir -p notes

for r in $REPOS; do
    if [[ ! -d $r ]]; then
        git clone -q git@github.com:quattor/$r.git
    fi
    cd $r
    git fetch -t 2> /dev/null
    git branch -r | grep $RELEASE > /dev/null && git checkout -q quattor-$RELEASE || git checkout -q master
    git pull -r > /dev/null
    from=$(git tag | grep $PREV'$')
    to=$(git tag | grep $RELEASE'$')
    git log $from..$to --oneline | grep -v '\[maven-release-plugin\]' | grep 'Merge pull request' | grep -o '#[0-9]\+' > ../notes/$r
    details="$details\n$r\t$(git branch | grep '^*')"
    cd ..
done
