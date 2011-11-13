Events = {}

-- CLASS METHODS
function Events:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.event_table = {}
  o.event_patterns = {}
  return o
end

--[[ 
to bind to multiple events, seperate the names with a pipe
event:bind("join|part", function(...) end)
--]]
function Events:bind(namestr, func)
  assert(namestr)
  assert(func)
  local names = string.split(namestr, "|")
  for i, name in ipairs(names) do
    local e = self.event_table[name] or {}
    e[func] = true
    self.event_table[name] = e
  end
  return func
end

function Events:unbind(name_list, func)
  assert(name_list)
  assert(func)
  local names = string.split(name_list, '|')
  for i, name in ipairs(names) do
    local e = self.event_table[name] or {}
    e[func] = nil
    self.event_table[name] = e
  end
  return func
end

--[[ Unbinds func after a single call
if conditional_unbind is non-nil, the function is only unbound when it returns true.
--]]
function Events:bind_once(name_list, func, conditional_unbind)
  local new_func
  new_func = function(...) 
    local result = func(...)
    if conditional_unbind and not result then return end
    self:unbind(unpack(name_list), new_func)
  end
  self:bind(name_list, new_func)
  return new_func
end

function Events:fire(name, ...)
  for f in pairs(self.event_table[name] or {}) do
    local event_object = EventObject:new(self, name, f)
    f(event_object, ...)
  end
end

EventObject = {}

function EventObject:new(events, name, func, o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.events = events
  o.context = events.context
  o.name = name
  o.func = func
  return o
end

function EventObject:unbind()
  self.events.unbind(self.name, self.func)
end
