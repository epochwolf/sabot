require "luarocks.loader"
require 'lib/util'
local lfs = require 'lfs'
local Plugin = require 'lib/plugin'
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
  return o
end

function PluginManager:load()
  for file in lfs.dir('./plugins') do
    local name, ext = unpack(split(file, '.'))
    if ext == "lua" then 
      local func, err = loadfile('plugins/'..file)
      if err then 
        error(err) 
      else
        self.plugins[name] = Plugin:new(self.bot, func)
      end
    end
  end
end

return PluginManager