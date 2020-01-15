FROM        ubuntu:16.04
MAINTAINER  Sebastian YEPES <syepes@gmail.com>

ENV         LANG=en_US.UTF-8 \
            LC_ALL=en_US.UTF-8 \
            PATH=/root/.cargo/bin:$PATH \
	    RUST_BACKTRACE=1

RUN         apt update \
            && apt install -y --no-install-recommends ca-certificates curl git gcc libssl-dev gcc-multilib \
            && curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2019-09-13 

RUN mkdir /tmp/sio2prom 
COPY . /tmp/sio2prom/

RUN         cd /tmp/ \
            && cd sio2prom \
	    && cargo build \
	    && rustup component add clippy \
            && cargo update \
            && cargo build --release \
            && mkdir -p /sio2prom/logs \
            && cp -rp cfg /sio2prom/ \
            && cp -rp target/release/sio2prom /sio2prom/ \
            && rm -rf /tmp/sio2prom \
            && cd \
            && rustup self uninstall -y \
            && yes 'Yes, do as I say!' |apt remove -y --force-yes --auto-remove curl gcc \
            && apt-get purge -y libc6-dev git perl-modules \
            && apt-get clean all \
            && rm -rf /usr/share/* \
            && rm -rf /var/lib/{apt,dpkg,cache,log}/*

EXPOSE      9186/TCP
WORKDIR     /sio2prom/
VOLUME      ["/sio2prom/cfg","/sio2prom/logs"]
CMD         ["/sio2prom/sio2prom"]

