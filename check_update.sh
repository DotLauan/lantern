#!/bin/bash

dir="$(cd `dirname $0`; pwd)"
echo "Workdir: $dir"

version=`curl -s https://api.github.com/repos/getlantern/lantern-binaries/commits \
    | grep '"message": "' \
    | grep 'Lantern [0-9\.]\+' \
    | head -1 \
    | sed 's/.*\(Lantern [0-9\.]*\).*/\1/g'`
if [[ -z $version ]]; then
    echo "Get latest version: error"
    exit 1
fi
echo "Get latest version: $version"

if [ ! -f "$dir/version" ]; then
    touch "$dir/version"
fi

oldver=`cat "$dir/version"`
echo "Get old version: $oldver"

if [ "$oldver" = "$version" ]; then
    echo 'Version not change.'
    exit 0
fi

echo 'Version change.'

# wget -o /tmp/wget.log -O ./binaries/lantern-installer-64-bit.deb https://github.com/getlantern/lantern-binaries/raw/main/lantern-installer-64-bit.deb

sed -i "1c # Docker 运行 $version，科学上网" README.MD
echo $version > "$dir/version"


git config --global user.name "Github Actions"
git config --global user.email "actions@github.com"
git status
git add .
git status
git commit -m "Github Actions auto update $version ()." &

tag=`echo $version | sed 's/Lantern //g'`
echo "Latest tag: $tag"

if [ `git tag | grep $tag | wc -l` = 0 ]; then
    echo "New tag: $tag"
    git tag "$tag"
else
    echo "Tag: $tag exist"
fi

git push --force origin master
git push --force origin --tags