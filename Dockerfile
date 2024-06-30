FROM docker.io/library/node:20.13.0-alpine

ENV PYTHONUNBUFFERED=1

# Install required dependencies and tools
RUN set -ex && \
    apk add --no-cache gcc g++ musl-dev python3 openjdk17 ruby iptables ip6tables bash lsof chromium rust cargo libc6-compat

# Install .NET SDK and runtime
RUN wget -O dotnet-install.sh https://dot.net/v1/dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh -c Current --install-dir /usr/share/dotnet

ENV PATH="$PATH:/usr/share/dotnet"

RUN set -ex && \
    rm -f /usr/libexec/gcc/x86_64-alpine-linux-musl/6.4.0/cc1obj && \
    rm -f /usr/libexec/gcc/x86_64-alpine-linux-musl/6.4.0/lto1 && \
    rm -f /usr/libexec/gcc/x86_64-alpine-linux-musl/6.4.0/lto-wrapper && \
    rm -f /usr/bin/x86_64-alpine-linux-musl-gcj

RUN ln -sf python3 /usr/bin/python

# Install Dart SDK
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip && \
    unzip dartsdk-linux-x64-release.zip -d /usr/lib/dart && \
    rm dartsdk-linux-x64-release.zip

ENV PATH="/usr/lib/dart/dart-sdk/bin:$PATH"

ADD . /usr/bin/
ADD start.sh /usr/bin/

RUN npm --prefix /usr/bin/ install
EXPOSE 8080

RUN addgroup -S -g 2000 runner && adduser -S -D -u 2000 -s /sbin/nologin -h /tmp -G runner runner
CMD sh /usr/bin/start.sh