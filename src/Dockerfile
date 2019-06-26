FROM tarantool/tarantool:latest
MAINTAINER doc@tarantool.org

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
    cmake \
    make \
    coreutils \
    gcc \
    g++ \
    lua-dev \
    git

RUN tarantoolctl rocks install document

COPY *.lua /opt/tarantool/
EXPOSE 3301 8080 443
WORKDIR /opt/tarantool

CMD ["tarantool", "app.lua"]
