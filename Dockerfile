FROM ruby:2.6.6

EXPOSE 3000
CMD ["rails", "s", "-b", "0.0.0.0"]

RUN apt-get update && apt-get install -y \
  shared-mime-info \
  nano \
  && apt-get clean

WORKDIR /fanficker

COPY Gemfile .
COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . ${PROJECT_HOME}
