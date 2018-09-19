FROM mattolson/base:14.04

ENV PG_MAJOR 9.4
ENV PG_VERSION 9.4.19-1.pgdg14.04+1

# Create the user first so it has the same uid/gid as any other user created in a similar fashion
RUN groupadd -r postgres && useradd -r -g postgres postgres

RUN mkdir /docker-entrypoint-initdb.d

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-common &&\
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf &&\
    apt-get install -y --no-install-recommends postgresql-$PG_MAJOR=$PG_VERSION postgresql-contrib-$PG_MAJOR=$PG_VERSION

RUN mkdir -p /var/run/postgresql &&\
    chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
