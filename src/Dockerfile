FROM tarantool/tarantool:latest
MAINTAINER doc@tarantool.org

COPY *.lua /opt/tarantool/
EXPOSE 3301 8080 443
WORKDIR /opt/tarantool

CMD ["tarantool", "app.lua"]
