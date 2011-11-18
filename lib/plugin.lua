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

function Plugin:new(api, code)
  assert(api)
  assert(code)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.api = api
  o.bot = api.bot
  o.code = code
  o.commands = {}
  o.command_help = {}
  o.bindings = {}
  -- execute plugin code
  local plugin_env = {bot = o.bot, plugin = o, console = console, api = o.api}
  setmetatable(plugin_env, {__index = _G})
  setfenv(o.code, plugin_env)
  o.code()
  
  return o
end

function Plugin:command(name, func)
  assert(name) 
  assert(func)
  self.commands[name] = true
  self:bind("command:"..name, func)
end

function Plugin:cmdhelp(name, help_str)
  self.command_help[name] = help_str
end

function Plugin:bind(event, func)
  local e = self.bindings[event] or {}
  e[func] = true
  self.bindings[event] = e
  self.bot.events:bind(event, func)
end

function Plugin:unbind(event, func)
  local e = self.bindings[event] or {}
  e[func] = nil
  self.bindings[event] = e
  self.bot.events:unbind(event, func)
end

-- internal method, does what it says
function Plugin:_unbind_all()
  for event, funcs in pairs(self.bindings) do
    for func in pairs(funcs) do
      self:unbind(event, func)
    end
  end
  self.commands = {}
  self.command_help = {}
  self.bindings = {}
end

return Plugin