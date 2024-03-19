ARG ELIXIR_VERSION=1.14.4
ARG OTP_VERSION=25.3
ARG ALPINE_VERSION=3.17.2

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apk add --no-cache --update git build-base nodejs npm

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build assets
COPY assets assets
RUN mix assets.deploy

# build release
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apk add --no-cache --update openssl libstdc++ ncurses

WORKDIR "/app"
RUN chown nobody:nobody /app
USER nobody:nobody

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:nobody /app/_build/prod/rel/oof ./

CMD /app/bin/oof start

# Appended by flyctl
ENV ERL_AFLAGS "-proto_dist inet6_tcp"
