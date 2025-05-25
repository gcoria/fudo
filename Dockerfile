FROM ruby:3.2-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "-p", "9292", "-o", "0.0.0.0"]