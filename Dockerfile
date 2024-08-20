FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y nasm gcc libc6-dev vim

WORKDIR /usr/src/app

COPY . .

CMD [ "/bin/bash" ]