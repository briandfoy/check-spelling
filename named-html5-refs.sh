#!/bin/sh
curl -L -s https://dev.w3.org/html5/html-author/charref | \
  perl -ne '
    next unless s!.*named!!;
    s!</code.*!!;
    s!.*>!!;
    s!([a-z][A-Z][a-z])([A-Z][a-z])!$1 $2!g;
    s!([a-z])([A-Z][A-Za-z])!$1 $2!g;
    s![& ;]!\n!g;
    $_ = lc $_;
    print' | \
  grep . | \
  sort -u -f > /tmp/charref.words
