ARG RUBY_VERSION=3.2.1
FROM ruby:${RUBY_VERSION}-slim-bullseye

RUN apt-get update && \
  apt-get install -y build-essential libpq-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN gem update --system && \
  gem install bundler:2.4.10

WORKDIR /app

ENV RAILS_ENV=production BUNDLE_WITHOUT=development RAILS_LOG_TO_STDOUT=1

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN bundle exec bootsnap precompile --gemfile app/ lib/

EXPOSE 3000
ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["./bin/rails", "server"]
