# PGBouncer  Docker image
![GitHub Tag](https://img.shields.io/github/v/tag/higgs01/pgbouncer)

This is a alpine-based docker-image for [PgBouncer](https://www.pgbouncer.org/).

## Features
- Lightweight (only ~13MB)
- envsubst for `pgbouncer.ini` and `userlist.txt` to allow injecting secrets at runtime
  - if the source-files change envsubst will be triggered again

## Usage
```bash
docker run \
    -p 5432:5432 \
    -v /etc/pgbouncer/input:/etc/pgbouncer/input # volume containing pgbouncer.ini and userlist.txt
    ghcr.io/higgs01/pgbouncer:latest
```

For an example see [docker-compose.dev.yml](./docker-compose.dev.yml)

## Config
This image doesn't provide a default configuration. Therefore you have to supply a [pgbouncer.ini](https://www.pgbouncer.org/config.html) and mount it as seen above.

### Environment-Variables
To inject secrets during runtime set those secret as an env-var and reference those in pgbouncer.ini` and `userlist.txt`

Example:
```yaml
# docker-compose.yml
services:
  pgbouncer:
    build: .
    volumes:
      - ./config:/etc/pgbouncer/input
    environment:
      POSTGRES_PASSWORD: password
```

```
# userlist.txt
"postgres" "$POSTGRES_PASSWORD"
```

This will then be rendered like this
```
# userlist.txt
"postgres" "password"
```
using [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)