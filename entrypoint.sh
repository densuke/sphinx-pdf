#!/bin/sh
RQ=requirements.txt
PRE=precmd

set -x
TEXDIR="$(grep TEXDIR /etc/texlive.profile|awk '{print $2}')"
PATH=$PATH:$(echo ${TEXDIR}/bin/* | head -n1)
set +x

if [ -f "${PRE}" ]; then
    echo "starting ${PRE}"
    sh ${PRE}
fi

# if [ -f Pipfile ]; then
#     pipenv install
# else
#     echo "create VirtualEnv"
#     pipenv install sphinx
# fi
#
if [ -f "$RQ" ]; then
    echo "installing requirements"
    pip install -r "${RQ}"
fi
#

echo "PATH: $PATH"

eval "$@"
