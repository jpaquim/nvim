#!/usr/bin/env fish

# for dir in lua/**/; mkdir -p (string replace lua fnl $dir); end
mkdir -p (string split ' ' (string replace -a lua fnl (fd -td . lua -X echo)))

# for file in **/*.lua; antifennel $file > (string replace -a lua fnl $file); end
fd -e lua -x fish -c 'exec antifennel {} > (string replace -a lua fnl {})'
