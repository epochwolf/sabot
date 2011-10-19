--[[
Class to manage the Bot. 
--]]
require 'events'
require 'connection'

Bot = {}
--major, minor, build
Bot.VERSION = {0, 1, 5}

function Bot:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.events = Events:new()
  o.connection = Connection:new{bot = o}
  return o
end