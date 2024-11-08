FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y \
        curl \
        wget \
        gpg \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
WORKDIR /Hello-world
COPY . /Hello-world/
RUN wget https://github.com/frenzywall/HelloWorld.deb/blob/main/public_key.gpg
RUN gpg --import public_key.gpg
RUN gpg --verify hello-world.deb.sig hello-world.deb
RUN dpkg -i hello-world
CMD ["/bin/bash"]