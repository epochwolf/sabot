local Channel = require 'lib/channel'
local Nick = require 'lib/nick'
local console = require 'lib/console'

local BotManager = {}

function BotManager:new(bot)
  assert(bot)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.bot = bot
  o.channels = o.bot.channels
  o.nicks = o.bot.nicks
  o.events = o.bot.events
  return o
end

function BotManager:get_channel(channel)
  if not self.channels[channel] then 
    self.channels[channel] = Channel:new(channel)
  end
  return self.channels[channel]
end

function BotManager:get_nick(nickstr)
  nick = Nick.components(nickstr)
  if self.nicks[nick] then 
    self.nicks[nick]:update(nickstr)
  else
    self.nicks[nick] = Nick:new(nickstr)
  end
  return self.nicks[nick]
end

function BotManager:nick_joined_channel(channel, nick)
  local channel = self:create_channel(channel)
  local nick = Nick.components(nickstr)
  channel:nick_joined(nick)
  
end

function BotManager:nick_parted_channel(channel, nick)
  
end

function BotManager:kicked_from_channel(channel, nick)
  
end

function BotManager:channel_names(channel, names)
  
end

function BotManager:set_modes(channel, mode_str)
  channel = self:create_channel(channel)
  channel.set_modes(mode_str)
end

function BotManager:set_topic(channel, topic)
  channel = self:create_channel(channel)
  channel.set_topic(topic)
end

function BotManager:_fire_delayed_funcs()
  if 0 == #self.bot.delayed_funcs then return end
  for i, f in ipairs(self.bot.delayed_funcs) do
    xpcall(f, console.error)
  end
  self.bot.delayed_funcs = {}
end

return BotManager