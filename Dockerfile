FROM alpine:3.14.1

WORKDIR /app
RUN chmod +x /app

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata
# for locale
ENV MUSL_LOCPATH /usr/share/i18n/locales/musl

# installing locales (source forgotten)
RUN \ 
apk update && \
apk add --no-cache cmake make musl-dev gcc gettext-dev libintl && wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip && \
unzip musl-locales-master.zip && \
cd musl-locales-master && \
cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install && \
cd .. && rm -r musl-locales-master

# installing dependencies (p7zip-rar / p7zip-full isn't avalible on alpine.) (most of these dependencies need to be cleaned up)
RUN \
apk add --no-cache \
    p7zip \
    git \
    aria2 \
    wget \
    curl \
    busybox \
    unzip \
    unrar \
    tar \
    python3 \ 
    python3-dev \ 
    py-pip \
    py3-pip \
    py3-yarl \
    py3-lxml \
    py3-cryptography \ 
    ffmpeg \
    alpine-sdk \ 
    build-base \
    jpeg-dev \
    zlib-dev\
    libxml2 \
    libxml2-dev \
    libxslt \
    libxslt-dev \
    gdk-pixbuf-dev \
    pango-dev \
    cairo-dev \
    openssl-dev \
    libxslt-dev \
    g++ 

# setup rar, unrar (i know unrar is already added but we need to setup rar)
RUN \
mkdir -p /tmp/ && \
    cd /tmp/ && \
    wget -O /tmp/rarlinux.tar.gz http://www.rarlab.com/rar/rarlinux-x64-6.0.0.tar.gz && \
    tar -xzvf rarlinux.tar.gz && \
    cd rar && \
    cp -v rar unrar /usr/bin/ && \
    rm -rf /tmp/rar*
    
# setup gclone
RUN \
mkdir /app/reaitten && \ 
wget -O /app/reaitten/gclone.gz https://github.com/donwa/gclone/releases/download/v1.51.0-mod1.3.1/gclone_1.51.0-mod1.3.1_Linux_x86_64.gz && \
gzip -d /app/reaitten/gclone.gz && \ 
chmod 0775 /app/reaitten/gclone 

# setup rclone
RUN curl https://rclone.org/install.sh | bash
# download files from repository
RUN wget -O /app/start.sh https://github.com/reaitten/tgtlg/raw/deploy-main/start.sh
RUN wget -O /app/extract https://github.com/reaitten/tgtlg/raw/deploy-main/extract

RUN pip3 install wheel --no-cache-dir
RUN pip3 install tgtlg --no-cache-dir

# to be audited out "rust"
#RUN pip3 install rust --no-cache-dir

# make extract have the proper permissions
RUN chmod +x extract

CMD ["bash","start.sh"]
