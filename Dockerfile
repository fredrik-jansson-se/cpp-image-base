FROM --platform=$BUILDPLATFORM gcc:15 AS build
ARG BUILDPLATFORM

RUN <<EOF
  apt-get update
  apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu cmake
EOF

# Setup openssl and install

ENV OPENSSL_VER=3.6.0
ENV JSON_VER=3.12.0
ENV BOOST_VER=1.89.0

ENV X86_64_DIR=/opt/linux/amd64
ENV AARCH_64_DIR=/opt/linux/arm64

RUN curl -LO https://github.com/openssl/openssl/releases/download/openssl-$OPENSSL_VER/openssl-${OPENSSL_VER}.tar.gz

WORKDIR /x86
RUN <<EOF
tar -xf ../openssl-$OPENSSL_VER.tar.gz
cd openssl-$OPENSSL_VER
./Configure --prefix="$X86_64_DIR"
make -j$(nproc) build_libs
make install_sw
EOF

WORKDIR /arm
RUN <<EOF
tar -xf ../openssl-$OPENSSL_VER.tar.gz
cd openssl-$OPENSSL_VER
./Configure linux-aarch64 --prefix="$AARCH_64_DIR" --cross-compile-prefix=aarch64-linux-gnu-
make -j$(nproc) build_libs
make install_sw
EOF

WORKDIR /
RUN curl -LO https://github.com/nlohmann/json/archive/refs/tags/v$JSON_VER.tar.gz
WORKDIR /x86
RUN <<EOF
tar -xf "../v$JSON_VER.tar.gz"
cd "json-$JSON_VER"
cmake -S . -B build --install-prefix="$X86_64_DIR"
make -j$(nproc) -C build
make -C build install
EOF

WORKDIR /arm
RUN <<EOF
tar -xf "../v$JSON_VER.tar.gz"
cd "json-$JSON_VER"
export CC=aarch64-linux-gnu-gcc
export CXX=aarch64-linux-gnu-g++
cmake -S . -B build --install-prefix="$AARCH_64_DIR"
make -j$(nproc) -C build
make -C build install
EOF

WORKDIR /
RUN <<EOF
curl -OL "https://github.com/boostorg/boost/releases/download/boost-$BOOST_VER/boost-$BOOST_VER-b2-nodocs.tar.gz"
EOF

WORKDIR /x86
RUN <<EOF
tar -xf "../boost-$BOOST_VER-b2-nodocs.tar.gz"
cd "boost-$BOOST_VER"
./bootstrap.sh --prefix="$X86_64_DIR"
./b2 
./b2 install
EOF

WORKDIR /arm
RUN <<EOF
tar -xf "../boost-$BOOST_VER-b2-nodocs.tar.gz"
cd "boost-$BOOST_VER"
echo "using gcc : aarch64 : aarch64-linux-gnu-g++ ;" > tools/build/src/user-config.jam
./bootstrap.sh --prefix="$AARCH_64_DIR"
./b2 toolset=gcc-aarch64
./b2 install
EOF

FROM gcc:15 AS final
ARG TARGETPLATFORM

COPY --from=build "/opt/$TARGETPLATFORM" /opt/$TARGETPLATFORM

ENV PKG_CONFIG_PATH="/opt/$TARGETPLATFORM/lib64/pkgconfig:/opt/$TARGETPLATFORM/share/pkgconfig"

# FROM final AS code
# WORKDIR /src
# COPY test.cpp .
#
# RUN <<EOF
# g++ -std=c++17 -O3 -o test \
#   $(pkg-config openssl --cflags) \
#   $(pkg-config nlohmann_json --cflags) \
#   test.cpp \
#   $(pkg-config openssl --libs)
# EOF

# FROM debian:13-slim
#
# COPY --from=code /src/test /usr/local/bin/.
#
# CMD ["/usr/local/bin/test"]
#
#
