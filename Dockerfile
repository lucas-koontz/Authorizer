FROM ruby:2.7.2-alpine

ARG BUILD_PACKAGES="build-base git openssh"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apk update \
    && apk upgrade \
    && apk add --no-cache $BUILD_PACKAGES

WORKDIR /gem

COPY . /gem

RUN gem install bundler && \
    bundle config --global --jobs $(nproc) && \
    bundle install && \
    rm -r /var/cache/apk/*
