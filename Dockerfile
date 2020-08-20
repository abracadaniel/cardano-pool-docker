from debian:stable-slim
LABEL maintainer="dro@arrakis.it"

# Install build dependencies
RUN apt-get update -y \
    && apt-get install -y python3 python3-pip build-essential pkg-config libffi-dev \
        libgmp-dev libssl-dev libtinfo-dev systemd libsystemd-dev zlib1g-dev libsodium-dev \
        npm yarn make g++ tmux git jq wget libncursesw5 gnupg libtool autoconf \
        vim procps dnsutils bc curl nano cron \
    && apt-get clean

# Install cabal
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz \
    && rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig \
    && mv cabal /usr/bin/ \
    && cabal clean && cabal update

# Install GHC
RUN wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && rm ghc-8.6.5-x86_64-deb9-linux.tar.xz \
    && cd ghc-8.6.5 \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf ghc-8.6.5

# Install libsodium
RUN git clone https://github.com/input-output-hk/libsodium \
    && cd libsodium \
    && git checkout 66f017f1 \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && make clean \
    && export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" 

# Install cardano-node
ARG CARDANO_BRANCH
ARG VERSION
RUN echo "Building $CARDANO_BRANCH..." \
    && echo $CARDANO_BRANCH > /CARDANO_BRANCH \
    && mkdir -p /cardano-node/ \
    && git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --tags \
    && git checkout $CARDANO_BRANCH \
    && cabal build all \
    && mkdir -p /root/.cabal/bin/ \
    && cp /cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-${VERSION}/x/cardano-node/build/cardano-node/cardano-node /root/.cabal/bin/ \
    && cp /cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-${VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli /root/.cabal/bin/ \
    && rm -rf /root/.cabal/packages && rm -rf ghc-8.6.5 && rm -rf /cardano-node/dist-newstyle/

# Expose ports
## cardano-node, EKG, Prometheus
EXPOSE 3000 12788 12798

# ENV variables
ENV NODE_PORT="3000" \
    NODE_NAME="node1" \
    NODE_TOPOLOGY="" \
    NODE_RELAY="False" \
    CARDANO_NETWORK="main" \
    EKG_PORT="12788" \
    PROMETHEUS_HOST="127.0.0.1" \
    PROMETHEUS_PORT="12798" \
    RESOLVE_HOSTNAMES="False" \
    REPLACE_EXISTING_CONFIG="False" \
    POOL_PLEDGE="100000000000" \
    POOL_COST="10000000000" \
    POOL_MARGIN="0.05" \
    METADATA_URL="" \
    PUBLIC_RELAY_IP="TOPOLOGY" \
    WAIT_FOR_SYNC="True" \
    AUTO_TOPOLOGY="True" \
    PATH="/root/.cabal/bin/:/scripts/:/scripts/functions/:/cardano-node/scripts/:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}" \
    CARDANO_NODE_SOCKET_PATH="DEFAULT"

# Add config
ADD cfg-templates/ /cfg-templates/
RUN mkdir -p /config/
VOLUME /config/

# Add scripts
RUN echo "source /scripts/init_node_vars" >> /root/.bashrc
ADD scripts/ /scripts/
RUN chmod -R +x /scripts/

ENTRYPOINT ["/scripts/start-cardano-node"]
