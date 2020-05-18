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

# Expose ports
## cardano-node, EKG, Prometheus
EXPOSE 3000-3001 12788-12789 12798-12799

# Expose volume
VOLUME /config/

# ENV variables
ENV PRODUCER_IP="" \
    PRODUCER_PORT="3000" \
    RELAY_IP="" \
    RELAY_PORT="3001" \
    CARDANO_NETWORK="pioneer" \
    CARDANO_NODE_SOCKET_PATH="/default.socket" \
ENV CARDANO_BRANCH "$cardano_branch"

# Install cardano-node
RUN mkdir -p /cardano-node/
RUN git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --tags \
    && git checkout ${CARDANO_BRANCH}
RUN cd cardano-node && cabal build all
RUN cd cardano-node && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-1.11.0/x/cardano-node/build/cardano-node/cardano-node /usr/bin \
    && cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-1.11.0/x/cardano-cli/build/cardano-cli/cardano-cli /usr/bin
WORKDIR /cardano-node/


# Add config
ADD config-templates/ /config-templates/
RUN mkdir -p /config/

# Add scripts
ADD scripts/ /scripts/
RUN chmod -R +x /scripts/


ENTRYPOINT ["/script/start-cardano-node.sh"]
