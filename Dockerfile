FROM ubuntu:focal
RUN apt update; \
    if [ `uname -m` = 'aarch64' ]; then \
        for i in /bin/* /usr/bin/*; do \
            if [ ! -e /usr/sbin/$(basename $i) ]; then \
                ln $i /usr/sbin/; \
            fi; \
        apt install -y lsb-release; ln -v /usr/bin/lsb_release /usr/bin/; \
        done; \
    fi; \
    apt install -y apt-utils; \
    apt install -y --no-install-recommends --no-install-suggests \
    xz-utils perl python3 python3-pip curl make; \
    apt clean; apt purge --auto-remove --purge -y apt-utils; apt clean
RUN pip install sphinx
COPY texlive.profile /etc/
RUN mkdir /tmp/work; cd /tmp/work; \
    curl -sL -O https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar xvzf install-tl-unx.tar.gz && rm -f  install-tl-unx.tar.gz; \
     cd *; \
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
