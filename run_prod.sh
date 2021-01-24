#!/bin/bash

export SECRET_KEY_BASE=$(mix phx.gen.secret)
export DATABASE_URL=ecto://ecaf:1234@192.168.1.144/ecaf_dev

mix deps.get --only prod
MIX_ENV=prod mix compile

npm run deploy --prefix ./assets
mix phx.digest

PORT=1312 MIX_ENV=prod mix phx.server