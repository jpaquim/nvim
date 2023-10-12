#!/usr/bin/env bash

DIR=../LazyVim
if [ -d $DIR ]; then
	pushd $DIR
	git fetch
	git reset --hard origin/main
	git clean -xf
	popd
else
	git clone --depth=1 https://github.com/LazyVim/LazyVim $DIR
fi

pushd $DIR/lua/lazyvim

mv config/init.lua config.lua
mv config/*.lua .
mv util/init.lua util.lua

rm init.lua
rmdir config

find . -type f -exec sed -i \
	-e 's/lazyvim\.config/config/g' \
	-e 's/lazyvim\.plugins/plugins/g' \
	-e 's/lazyvim\.util/util/g' \
	-e 's/config\.init/config/g' \
	-e 's/config\.options/options/g' \
	{} +

popd

rsync -a $DIR/lua/lazyvim/ lua/
