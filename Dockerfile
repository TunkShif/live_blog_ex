ARG MIX_ENV="prod"
FROM hexpm/elixir:1.12.3-erlang-24.1.7-alpine-3.14.2 as build

RUN apk add --no-cache build-base git python3 curl yarn

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"
COPY mix.exs mix.lock ./

RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

RUN cd assets && yarn install
RUN mix assets.deploy
RUN mix compile

COPY config/runtime.exs config/
RUN mix release

FROM alpine:3.14.2 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs

ARG MIX_ENV
ENV USER="elixir"

WORKDIR "/home/${USER}/app"
# Creates an unprivileged user to be used exclusively to run the Phoenix app
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"

# Everything from this line onwards will run in the context of the unprivileged user.
USER "${USER}"

COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/live_blog_ex ./

ENTRYPOINT ["bin/live_blog_ex"]

# Usage:
#  * build: sudo docker image build -t elixir/my_app .
#  * shell: sudo docker container run --rm -it --entrypoint "" -p 127.0.0.1:4000:4000 elixir/my_app sh
#  * run:   sudo docker container run --rm -it -p 127.0.0.1:4000:4000 --name my_app elixir/my_app
#  * exec:  sudo docker container exec -it my_app sh
#  * logs:  sudo docker container logs --follow --tail 100 my_app
CMD ["start"]
