FROM ruby:3.3.3

# Set env variables
# Ofc not good practice, but I do it only for testing this API purposes
ENV IPSTACK_API_KEY="3487eca75c17edf261bb558c66582dd0"

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
