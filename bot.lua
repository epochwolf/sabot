--[[
Class to manage the Bot. 
--]]

Bot = {}

function Bot:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end