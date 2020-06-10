FROM debian:stable-slim
LABEL maintainer="dro@arrakis.it"

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
ARG CARDANO_BRANCH="tags/1.13.0"
RUN echo "Building $CARDANO_BRANCH..." \
    && echo $CARDANO_BRANCH > /CARDANO_BRANCH
RUN git clone https://github.com/input-output-hk/cardano-node.git \
    && cd cardano-node \
    && git fetch --all --tags \
    && git checkout $CARDANO_BRANCH
WORKDIR /cardano-node/
RUN cabal install cardano-node cardano-cli

# Install python
# RUN apt-get install -y python3 python3-pip vim

# Expose ports
## cardano-node, EKG, Prometheus
EXPOSE 3000 12788 12798

# ENV variables
# ENV NODE_PORT="3000" \
#     NODE_NAME="node1" \
#     NODE_TOPOLOGY="" \
#     NODE_RELAY="False" \
#     CARDANO_NETWORK="main" \
#     EKG_PORT="12788" \
#     PROMETHEUS_PORT="12798" \
#     RESOLVE_HOSTNAMES="False" \
#     REPLACE_EXISTING_CONFIG="False" \
ENV PATH="/root/.cabal/bin/:/new-scripts/:/cardano-node/scripts/:${PATH}"

ADD new-scripts/ /new-scripts/
RUN chmod -R +x /new-scripts/
COPY start-cardano-node.sh /start-cardano-node.sh
RUN chmod +x /start-cardano-node.sh

# CMD [ "cardano-node", "run", "--topology", "ff-topology.json", "--socket-path", "db/node.socket", "--config", "ff-config.json", "--database-path", " db" ]
# CMD [ "ls", "/" ]
ENTRYPOINT [ "/start-cardano-node.sh" ]