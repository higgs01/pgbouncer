FROM alpine:3.21.0 AS build
ARG PGBOUNCER_VERSION=1.23.1

RUN apk add --no-cache gcc make libevent-dev pkgconfig autoconf libc-dev libtool autoconf automake openssl-dev

RUN wget https://www.pgbouncer.org/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz -O /pgbouncer.tar.gz 
RUN tar -xzf /pgbouncer.tar.gz && mv /pgbouncer-${PGBOUNCER_VERSION} /pgbouncer

WORKDIR /pgbouncer

RUN ./configure --prefix=/usr/local
RUN make
RUN make install

FROM alpine:3.21.0

RUN apk add --no-cache libevent postgresql-client bash envsubst inotify-tools
RUN mkdir -p /etc/pgbouncer/input /etc/pgbouncer/runtime /var/log/pgbouncer && chown -R postgres /etc/pgbouncer /var/log/pgbouncer
RUN touch /etc/pgbouncer/input/pgbouncer.ini && touch /etc/pgbouncer/input/userlist.txt

COPY entrypoint.sh /entrypoint.sh
COPY config-watcher.sh /config-watcher.sh
COPY --from=build /pgbouncer/pgbouncer /usr/bin

RUN chmod a+rx /entrypoint.sh /config-watcher.sh && chown postgres /entrypoint.sh /config-watcher.sh

USER postgres
EXPOSE 5432
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/runtime/pgbouncer.ini"]
