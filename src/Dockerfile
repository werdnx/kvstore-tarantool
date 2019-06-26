FROM tarantool/tarantool:latest
MAINTAINER doc@tarantool.org

COPY *.lua /opt/tarantool/
EXPOSE 3301
WORKDIR /opt/tarantool

CMD ["tarantool", "app.lua"]
