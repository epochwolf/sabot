local PluginApi = {}
local Channel = require 'lib/channel'
local assert = assert
local setmetatable = setmetatable

function PluginApi:new(bot)
  assert(bot)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.bot = bot
  o.connection = bot.connection
  return o
end

function PluginApi:msg(channel, message)
  assert(channel)
  assert(message)
  self.connection:send_privmsg(channel, message)
end

function PluginApi:action(channel, message)
  assert(channel)
  assert(message)
  self.connection:send_action(channel, message)
end

function PluginApi:join(channel)
  assert(channel)
  self.connection:send_join(channel)
end

function PluginApi:part(channel)
  assert(channel)
  self.connection:send_part(channel)
end

function PluginApi:get_bot_nick()
  return self.bot.nick
end

function PluginApi:is_channel(channel)
  return Channel.is_channel(channel)
end


return PluginApi