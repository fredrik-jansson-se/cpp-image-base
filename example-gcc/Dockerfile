# vi: ft=dockerfile
FROM ghcr.io/fredrik-jansson-se/cpp-image-base:main AS code
ARG TARGETPLATFORM
WORKDIR /src
COPY test.cpp .

RUN <<EOF
g++ -std=c++17 -O3 -o test \
  $(pkg-config openssl --cflags) \
  $(pkg-config nlohmann_json --cflags) \
  test.cpp \
  $(pkg-config openssl --libs) \
  -L "/opt/$TARGETPLATFORM/lib" \
  -l boost_thread
EOF

FROM debian:13-slim
ARG TARGETPLATFORM

COPY --from=code /src/test /usr/local/bin/.
COPY --from=code "/opt/$TARGETPLATFORM/lib/libboost_thread.so.1.89.0" "/opt/$TARGETPLATFORM/lib/."
COPY --from=code "/opt/$TARGETPLATFORM/lib/libboost_date_time.so.1.89.0" "/opt/$TARGETPLATFORM/lib/."
COPY --from=code "/opt/$TARGETPLATFORM/lib/libboost_atomic.so.1.89.0" "/opt/$TARGETPLATFORM/lib/."
COPY --from=code "/opt/$TARGETPLATFORM/lib/libboost_container.so.1.89.0" "/opt/$TARGETPLATFORM/lib/."
COPY --from=code "/opt/$TARGETPLATFORM/lib/libboost_chrono.so.1.89.0" "/opt/$TARGETPLATFORM/lib/."
ENV LD_LIBRARY_PATH="/opt/$TARGETPLATFORM/lib"

CMD ["/usr/local/bin/test"]
