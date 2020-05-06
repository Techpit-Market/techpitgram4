FROM ruby:2.5.1-slim-stretch as base

RUN apt-get update -qq && \
  apt-get install -y \
    nodejs \
    postgresql-client \
    imagemagick \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libpq-dev \
    libsqlite3-dev

RUN mkdir /techpitgram
WORKDIR /techpitgram
COPY Gemfile /techpitgram/Gemfile
COPY Gemfile.lock /techpitgram/Gemfile.lock

RUN bundle install
COPY . /techpitgram

# コンテナの起動時に実行したいスクリプト指定
COPY tools/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Railsを起動
CMD ["rails", "server", "-b", "0.0.0.0"]