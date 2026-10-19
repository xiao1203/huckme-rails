# Intentionally vulnerable lab app — for authorized security tool testing only.
# Do not expose this image or container to the public internet.
FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential \
      libyaml-dev \
      libsqlite3-dev \
      sqlite3 \
      iputils-ping \
      curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

RUN mkdir -p storage/uploads tmp/pids

EXPOSE 3000

CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails db:prepare && bin/rails db:seed && bin/rails server -b 0.0.0.0"]
