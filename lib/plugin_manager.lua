require "luarocks.loader"
require 'lib/util'
local lfs = require 'lfs'
local Plugin = require 'lib/plugin'
local PluginApi = require 'lib/plugin_api'
local error = error
local unpack = unpack
local split = string.split

local PluginManager = {}

function PluginManager:new(bot)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.bot = bot
  o.plugins = {}
  o.api = PluginApi:new(bot)
  o.env = {api = api, }
  return o
end

function PluginManager:load()
  print("Loading all plugins")
  for file in lfs.dir('./plugins') do
    local name, ext = unpack(split(file, '.'))
    if ext == "lua" then 
      local func, err = loadfile('plugins/'..file)
      if err then 
        error(err) 
      else
        self.plugins[name] = Plugin:new(self.api, func)
      end
    end
  end
end

function PluginManager:reload()
  print("Unbinding all plugins")
  for name, plugin in pairs(self.plugins) do
    print("Unbinding plugin: "..name)
    plugin:_unbind_all()
  end
  self.plugins = {}
  self:load()
end

return PluginManager