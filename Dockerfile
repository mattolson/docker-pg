FROM mattolson/base

# Get these from `apt-cache policy` after installing pgdg as stated below
ENV PG_MAJOR=17
ENV PG_VERSION=17.5-1.pgdg24.04+1
ENV PG_CONTRIB_VERSION=16+257build1.1

# Create the user first so it has the same uid/gid as any other user created in a similar fashion
RUN groupadd -r postgres && useradd -r -g postgres postgres

RUN mkdir /docker-entrypoint-initdb.d

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update &&\
    apt-get install -y --no-install-recommends postgresql-common &&\
    sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf &&\
    apt-get install -y --no-install-recommends postgresql-$PG_MAJOR=$PG_VERSION postgresql-contrib=$PG_CONTRIB_VERSION

RUN mkdir -p /var/run/postgresql &&\
    chown -R postgres /var/run/postgresql

ENV PATH=/usr/lib/postgresql/$PG_MAJOR/bin:$PATH
ENV PGDATA=/var/lib/postgresql/data

VOLUME /var/lib/postgresql/data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres"]
