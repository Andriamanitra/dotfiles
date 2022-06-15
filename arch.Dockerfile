# Dockerfile for Arch Linux with some basic tools pre-installed

FROM archlinux:latest
RUN pacman --noconfirm -Syu cmake fish git jq micro python python-virtualenv tealdeer wget
ENV EDITOR=micro
COPY fish/.config/fish/functions/fish_prompt.fish /etc/fish/conf.d/
CMD fish
