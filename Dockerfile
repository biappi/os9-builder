FROM debian:latest

RUN dpkg --add-architecture i386
RUN apt update
RUN apt install --no-install-recommends -y wine wine32 patch

COPY os9_68k_sdk_v12 /os9-sdk-v12
COPY os9-m68k-ports  /os9-m68k-ports

RUN mkdir -p /root/.wine/dosdevices/m:
RUN ln -s /os9-sdk-v12/ /root/.wine/dosdevices/m:/MWOS

COPY disable-cfide.patch /disable-cfide.patch
RUN cd /os9-m68k-ports && patch -p1 < /disable-cfide.patch
