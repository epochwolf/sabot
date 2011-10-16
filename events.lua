Events = {}


-- CLASS METHODS
function Events:new()
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.event_table = {}
  return o
end

--INSTANCE METHODS
function Events:bind(name, func)
    local e = self.event_table[name] or {}
    e[func] = true
    self.event_table[name] = e
end

function Events:unbind(name, func)
    local e = self.event_table[name] or {}
    e[func] = nil
    self.event_table[name] = e
end

function Events:fire(name, ...)
    for f in pairs(self.event_table[name] or {}) do
        f(name, ...)
    end
end