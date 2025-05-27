CREATE ROLE monitor WITH LOGIN PASSWORD 'm$$n3yt0r4';

CREATE ROLE richard WITH LOGIN PASSWORD 'richard' SUPERUSER;

CREATE ROLE pgpool_exporter WITH LOGIN PASSWORD 'pgpool_exporter';

GRANT pg_monitor TO monitor;

GRANT pg_monitor TO pgpool_exporter;