FROM        ubuntu:16.04

MAINTAINER WikiToLearn akhet@wikitolearn.org

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

ENV DISPLAY :0

ADD ./sources.list /etc/apt/sources.list

RUN apt-get update && apt-get dist-upgrade --assume-yes --force-yes && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install x11vnc && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install python && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install python-numpy && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install xserver-xorg-video-dummy && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install supervisor && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete
RUN apt-get update && apt-get -y --force-yes install git && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete && find /var/log/ -type f -delete

RUN git clone https://github.com/kanaka/websockify /websockify

RUN mkdir /root/.vnc/

RUN useradd -m user -u 1000 -s /bin/bash

ADD ./run.sh /run.sh
ADD ./xorg.conf /etc/X11/xorg.conf

EXPOSE 5900 6080

CMD ["/run.sh"]

LABEL virtualfactoryimage=true
