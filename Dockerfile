FROM ruby:2.3.3
LABEL maintainer="Dongfeng Gu <gudongfeng@outlook.com>"

# Ensure that our apt package list is updated and install a few
# packages to ensure that we can compile assets (nodejs) and
# communicate with PostgreSQL (libpq-dev).
RUN apt-get update -qq && apt-get install -y \
      build-essential nodejs libpq-dev`

# Define the project path
ENV INSTALL_PATH /TalkWithSam

# Create the folder for the project
RUN mkdir -p $INSTALL_PATH

# We're going to be executing a number of commands below, and
# having to CD into the /my_dockerized_app folder every time would be
# lame, so instead we can set the WORKDIR to be /my_dockerized_app.
WORKDIR $INSTALL_PATH

# This is going to copy in the Gemfile and Gemfile.lock from our
# work station at a path relative to the Dockerfile to the
# my_dockerized_app/ path inside of the Docker image.
ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock

# We want binstubs to be available so we can directly call sidekiq and
# potentially other binaries as command overrides without depending on
# bundle exec.
RUN bundle install

# Copy the whole project to the image file
ADD . .