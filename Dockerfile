# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.1
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS="4" \
    BUNDLE_RETRY="3" \
    BUNDLE_WITHOUT="test" \
    PATH="/rails/bin:${PATH}"

# -------------------------
# STAGE 1: Build (compila gems nativas)
# -------------------------
FROM base AS build

# Instala dependências de compilação (bcrypt, pg, etc.)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libvips \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Copia Gemfile e Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instala gems (bcrypt será compilado aqui)
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia o restante do código
COPY . .
RUN bundle exec bootsnap precompile app/ lib/

# -------------------------
# STAGE 2: Runtime (produção/desenvolvimento)
# -------------------------
FROM base

# Instala apenas dependências de runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    postgresql-client \
    redis-tools && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copia as gems já compiladas e o código do estágio build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Cria usuário Rails
RUN useradd rails --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp tmp/pids && \
    chown -R rails:rails db log storage tmp && \
    chmod +x /rails/bin/docker-entrypoint

USER rails:rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
