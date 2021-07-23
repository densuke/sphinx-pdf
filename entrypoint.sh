#!/bin/sh
RQ=requirements.txt
PRE=precmd

set -x
TEXDIR="$(grep TEXDIR /etc/texlive.profile|awk '{print $2}')"
TEXBIN="$(cat /etc/texbin.path"
PATH="$PATH:${TEXBIN}"
set +x

if [ -f "${PRE}" ]; then
    echo "starting ${PRE}"
    sh ${PRE}
fi

if [ -f "$RQ" ]; then
    echo "installing requirements"
    pip install -r "${RQ}"
fi
#

echo "PATH: $PATH"

eval "$@"
