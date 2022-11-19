FROM public.ecr.aws/docker/library/ruby:3.1.2-slim-bullseye AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /api
COPY ./api /api

RUN mkdir tmp/sockets && bundle install

FROM public.ecr.aws/docker/library/ruby:3.1.2-slim-bullseye

RUN apt-get update && apt-get install -y \
    libpq-dev \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /api

COPY --from=builder ./api /api
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

VOLUME ./api/tmp

CMD startup.sh
