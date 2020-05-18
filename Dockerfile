from debian:stable-slim
LABEL maintainer="droe@pm.me"

# Install build dependencies
RUN apt-get update -y \
    && apt-get install -y build-essential pkg-config libffi-dev \
        libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev \
        make g++ tmux git jq wget libncursesw5 dnsutils

# Install cabal
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig \
    && mv cabal /usr/bin/ \
    && cabal update

# Install GHC
RUN wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && rm ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && cd ghc-8.6.5 \
    && ./configure \
    && make install && cd ..

# Install cardano-node
ENV CARDANO_TAG "pioneer"
RUN git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --tags \
    && git checkout tags/${CARDANO_TAG}
RUN cd cardano-node && cabal build all
RUN cd cardano-node && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-1.11.0/x/cardano-node/build/cardano-node/cardano-node /usr/bin \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-1.11.0/x/cardano-cli/build/cardano-cli/cardano-cli /usr/bin

# Add config
RUN mkdir -p /cardano-node/
WORKDIR /cardano-node/
ADD config-templates/ /cardano-node/config-templates/
RUN mkdir -p /config/

# Expose ports
## cardano-node
EXPOSE 3000-3001
## EKG
EXPOSE 12788-12789
## Prometheus
EXPOSE 12798-12799

# Expose volume
VOLUME /config/

# ENV variables
ENV PRODUCER_IP ""
ENV PRODUCER_PORT "3000"
ENV RELAY_IP ""
ENV RELAY_PORT "3001"
ENV CARDANO_NETWORK "pioneer"
ENV CARDANO_NODE_SOCKET_PATH "/default.socket"

# Add scripts
ADD scripts/ /cardano-node/docker-scripts/
RUN chmod -R +x /cardano-node/docker-scripts/

ENTRYPOINT ["/cardano-node/docker-scripts/start-cardano-node.sh"]