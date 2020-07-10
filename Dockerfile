# ベースイメージを選定する
FROM ruby:2.5.1-slim-stretch as base

# アプリケーションに必要なツール・ライブラリを整理する
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
    libpq-dev

# アプリケーションの実行ディレクトリを作成
RUN mkdir /techpitgram
# 実行時のディレクトリに指定
WORKDIR /techpitgram

# Railsとして起動するための依存ライブラリをインストール
COPY Gemfile /techpitgram/Gemfile
COPY Gemfile.lock /techpitgram/Gemfile.lock
RUN bundle install --without development test

# アプリケーションをコピー
COPY . /techpitgram

# コンテナの起動時に実行したいスクリプト指定
COPY tools/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Railsを起動
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
