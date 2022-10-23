FROM public.ecr.aws/docker/library/ruby:slim-bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /api
COPY ./api /api
RUN bundle install

COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

VOLUME ./backend/tmp

CMD startup.sh
