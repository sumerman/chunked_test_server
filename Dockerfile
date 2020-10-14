FROM elixir:1.10-alpine

RUN mix local.hex --force && \
    mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY mix* ${APP_HOME}/
RUN mix deps.get && mix compile

ADD lib ./lib
RUN mix compile

CMD ["mix", "run", "--no-halt", "--no-compile", "--no-deps-check"]