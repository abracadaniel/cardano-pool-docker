FROM haskell:8.6.5 as build
WORKDIR /build
RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential=12.3 \
  git=1:2.11.*
RUN stack upgrade --binary-version 2.1.3

# Install bech32
ARG VERSION
RUN echo "Building tags/v$VERSION..." \
    && git clone https://github.com/input-output-hk/bech32.git \
    && cd bech32 \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout tags/v$VERSION

RUN stack setup \
  && stack init \
  && stack build \
  && stack install --flag bech32:release

# Run
FROM frolvlad/alpine-glibc:alpine-3.11_glibc-2.30
RUN apk add --no-cache gmp=6.1.2-r1 bash=5.0.11-r1 bash-completion=2.9-r0
COPY --from=build /root/.local/bin /bin

ENTRYPOINT ["bech32"]