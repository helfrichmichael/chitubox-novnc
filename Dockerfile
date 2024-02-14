# Get and install Easy noVNC.
FROM golang:1.22.0-bookworm AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

# Get TigerVNC and Supervisor for isolating the container.
FROM debian:bookworm
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# Get all of the remaining dependencies for the OS, VNC, and CHITUBOX.
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip && \
    rm -rf /var/lib/apt/lists

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        lxde gtk2-engines-murrine gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        libgtk2.0-dev libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri  \
        xdg-utils locales locales-all pcmanfm jq curl git firefox-esr \
       '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install CHITUBOX
WORKDIR /chitubox

# Note: On the next to lines, you will need to use Chrome or Firefox to start the download in your browser, then cancel it and copy the download URL to the line below.
# For the line below that, copy the file name with the auth_key bits like shown here.
RUN wget https://download.chitubox.com/17839/v1.9.5/CHITUBOX_V1.9.5.tar.gz?auth_key=1707873421-bxnqunqfbuike4u5ycmwu4oxrnyp4jqb-0-5fbe2fc8d2afcd12b07aaa126bdc132a \
  && mv CHITUBOX_V1.9.5.tar.gz?auth_key=1707873421-bxnqunqfbuike4u5ycmwu4oxrnyp4jqb-0-5fbe2fc8d2afcd12b07aaa126bdc132a CHITUBOX_V1.9.5.tar.gz \
  && mkdir -p /chitubox/ \
  && tar -xf CHITUBOX_V1.9.5.tar.gz -C /chitubox/ \
  && rm -f CHITUBOX_V1.9.5.tar.gz \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get autoclean \
  && groupadd chitubox \
  && useradd -g chitubox --create-home --home-dir /home/chitubox chitubox \
  && mkdir -p /chitubox \
  && mkdir -p /configs \
  && mkdir -p /prints/ \
  && chown -R chitubox:chitubox /chitubox/ /home/chitubox/ /prints/ /configs/ \
  && locale-gen en_US \
  && mkdir /configs/.local \
  && mkdir -p /configs/.config/ \
  && ln -s /configs/.config/ /home/chitubox/ \
  && mkdir -p /home/chitubox/.config/ \
  # We can now set the Download directory for Firefox and other browsers. 
  # We can also add /prints/ to the file explorer bookmarks for easy access.
  && echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/chitubox/.config/user-dirs.dirs \
  && echo "file:///prints prints" >> /home/chitubox/.gtk-bookmarks 

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/

# HTTP Port
EXPOSE 8080

# VNC Port
EXPOSE 5900

VOLUME /configs/
VOLUME /prints/

# It's time! Let's get to work! We use /configs/ as a bindable volume for CHITUBOXs configurations. We use /prints/ to provide a location for STLs and GCODE files.
CMD ["bash", "-c", "chown -R chitubox:chitubox /home/chitubox/ /configs/ /prints/ /dev/stdout && exec gosu chitubox supervisord"]