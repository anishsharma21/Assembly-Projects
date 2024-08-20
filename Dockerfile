FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y nasm gcc neovim

WORKDIR /usr/src/app

COPY . .

CMD [ "/bin/bash" ]