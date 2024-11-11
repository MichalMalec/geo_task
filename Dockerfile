FROM ruby:3.3.3

# Install dependencies required by gems
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  postgresql-client

WORKDIR /app

# Copy Gemfile, Gemfile.lock and bundle
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest
COPY . .

# Set port
EXPOSE 3000

# Run Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
