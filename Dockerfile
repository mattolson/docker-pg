FROM mattolson/base

ENV PG_MAJOR 9.0
ENV PG_VERSION 9.0.19-1.pgdg70+1

# Create the user first so it has the same uid/gid as any other user created in a similar fashion
RUN groupadd -r postgres && useradd -r -g postgres postgres

RUN mkdir /docker-entrypoint-initdb.d

RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 &&\
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-common &&\
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf &&\
    apt-get install -y --no-install-recommends postgresql-$PG_MAJOR=$PG_VERSION postgresql-contrib-$PG_MAJOR=$PG_VERSION &&\
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/postgresql &&\
    chown -R postgres /var/run/postgresql

ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA /var/lib/postgresql/data

VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
