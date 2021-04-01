#!/bin/bash

source conf_env.sh

# Setup elixir variables
export SECRET_KEY_BASE=$(mix phx.gen.secret)
export DATABASE_URL=ecto://$DB_USERNAME:$DB_PASSWORD@$DB_HOSTNAME/$DB_DATABASE
export MIX_ENV=prod
export PORT=1312

mix deps.get --only prod
mix compile

npm run deploy --prefix ./assets
mix phx.digest

mix phx.server