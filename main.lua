local Bot = require "lib/bot"
local config = require "config"

local bot = Bot:new(config)
bot:enable_debugging()
local success, errors = bot:connect()
if success then
  bot:run()
else
  print(errors)
end