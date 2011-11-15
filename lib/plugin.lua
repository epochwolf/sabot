local setfenv = setfenv
local console = require "lib/console"
local cprint = console.color
local Plugin = {
  name = "unnamed_plugin",
  version = {0, 0, 0},
  author = "unknown author",
  description = "The author is too lazy to provide a description",
  code = function() end,
}

function Plugin:new(bot, code)
  assert(bot)
  assert(code)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.bot = bot
  o.code = code
  -- execute plugin code
  plugin_env = {bot = o.bot, plugin = o}
  setmetatable(plugin_env, {__index = _G})
  setfenv(o.code, plugin_env)
  o.code()
  
  return o
end

function Plugin:command(name, func)
  self.bot.events:bind("command:"..name, func)
end

function Plugin:bind(event, func)
  self.bot.events:bind(event, func)
end

return Plugin