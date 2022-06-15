# Dockerfile for Ubuntu with some basic tools pre-installed

FROM ubuntu:latest
RUN apt-get update \
    && apt-get install -y bat curl cmake fish git iputils-ping micro python3.10 virtualenv wget \
    && rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/batcat /usr/bin/bat
ENV EDITOR=micro
COPY fish/.config/fish/functions/fish_prompt.fish /etc/fish/conf.d/
CMD fish
