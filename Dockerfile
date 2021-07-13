FROM ubuntu:focal
ARG http_proxy ''
ARG https_proxy ${http_proxy}
RUN apt update; apt install -y --no-install-recommends --no-install-suggests \
    xz-utils perl python3 python3-pip curl make; \
    apt clean
RUN pip install pipenv sphinx
COPY texlive.profile /etc/
RUN mkdir /tmp/work; cd /tmp/work;\
    curl -sL https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xz;  cd *; \
    ./install-tl -print-arch | awk '{printf("binary_%s 1", $0)}' | tee -a /etc/texlive.profile > /dev/null;\
    ./install-tl -profile  /etc/texlive.profile
RUN cd /tmp/work/*; TEXBIN=/opt/texlive/2021/bin/$(./install-tl --print-arch); PATH=$PATH:$TEXBIN; \
    tlmgr install latexmk cmap amsmath kvoptions graphics ltxcmds kvsetkeys float \
    wrapfig capt-of tools framed fancyvrb upquote needspace tabulary varwidth parskip fancyhdr \
    titlesec geometry hyperref pdftexcmds infwarerr oberdiek
RUN cd /tmp/work/*; TEXBIN=/opt/texlive/2021/bin/$(./install-tl --print-arch); PATH=$PATH:$TEXBIN; \
    tlmgr install xkeyval everyhook svn-prov etoolbox \
        wrapfig capt-of framed fancyvrb tabulary parskip fancyhdr titlesec geometry

# RUN cd $(grep TEXDIR /etc/texlive.profile | cut -d' ' -f2)/bin; \
#     if [ -d `uname -m`-linuxmusl ]; then ln -s `uname -m`-linuxmusl `uname -m`; fi
# COPY entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/entrypoint.sh
# ENV PATH ${PATH}:/usr/local/texlive/2021/bin/x86_64-linuxmusl
# ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

WORKDIR /work
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
