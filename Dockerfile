FROM ruby:2.4.1

ADD ./ /app
WORKDIR /app/bin

VOLUME /data

RUN bundle install

ENTRYPOINT ["bundle", "exec"]
