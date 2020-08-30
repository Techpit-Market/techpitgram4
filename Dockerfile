# syntax=docker/dockerfile:experimental

# ベースイメージを選定する
FROM ruby:2.5.1-slim-stretch as techpitgram-depends-all

# credential-helper を PATH が通っているところに置く
COPY git-credential-github-token /usr/local/bin

# アプリケーションに必要なツール・ライブラリを整理する
RUN apt-get update -qq && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y  --no-install-recommends \
    imagemagick \
    build-essential \
    patch \
    ruby-dev \
    zlib1g-dev \
    liblzma-dev \
    libxml2-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    git && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

# credential-helper を利用できるようにする
RUN git config --global url."https://github.com".insteadOf ssh://git@github.com && \
  git config --global --add url."https://github.com".insteadOf git://git@github.com && \
  git config --global --add url."https://github.com/".insteadOf git@github.com: && \
  git config --global credential.helper github-token && \
  chmod +x /usr/local/bin/git-credential-github-token

# アプリケーションの実行ディレクトリを作成
RUN mkdir /techpitgram
# 実行時のディレクトリに指定
WORKDIR /techpitgram

# Railsとして起動するための依存ライブラリをインストール
COPY Gemfile /techpitgram/Gemfile
COPY Gemfile.lock /techpitgram/Gemfile.lock

# 認証情報を実行時に受け取るように設定し、bundle install を行う
RUN --mount=type=secret,id=token,dst=/.github-token \
 . /.github-token && \
 bundle install

# アプリケーションをコピー
COPY . /techpitgram

FROM techpitgram-depends-all as techpitgram-build-assets

# assetのビルド
RUN bundle exec rails assets:precompile

FROM techpitgram-depends-all as techpitgram-app

# ビルドした asset をコピーする
COPY --from=techpitgram-build-assets /techpitgram/public/assets /techpitgram/public

# コンテナの起動時に実行したいスクリプト指定
COPY tools/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Railsを起動
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]