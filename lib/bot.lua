local Events = require 'lib/events'
local Connection = require 'lib/connection'
local BotManager = require 'lib/bot_manager'
local PluginManager = require 'lib/plugin_manager'

local Bot = {}

function Bot:new(config)
  assert(config)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.events = Events:new(o)
  o.channels = {}
  o.nicks = {}
  o.config = config
  o.nick = nil
  o.delayed_funcs = {}
  o.manager = BotManager:new(o)
  o.connection = Connection:new(config, o.manager)
  o.plugin_manager = PluginManager:new(o)
  o.plugin_manager:load()
  return o
end

function Bot:connect()
  return self.connection:connect()
end

function Bot:run()
  self.connection:handshake()
  while self.connection:receive() do end
end

function Bot:enable_debugging()
  self.connection:activate_socket_debugging()
  self.connection:activate_event_tracing()
end

function Bot:nick_is_admin(nick)
  if self.config.admins[nick] then
    return true
  else
    return false
  end
end

-- used to run a command after all events have been finished
-- useful for modifying plugin and event data. It's a but unsafe to do so
-- in an event
function Bot:set_delayed_func(func)
  self.delayed_funcs[#self.delayed_funcs + 1] = func
end

return Bot