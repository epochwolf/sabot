plugin.name = "System"
plugin.version = {0, 0, 1}
plugin.author = "epochwolf"
plugin.description = "Basic commands for the bot"

plugin:command("hi", function(e, channel, nick, args)
  if not args then
    bot:msg(channel, "Hi "..nick)
  else
    bot:msg(channel, "Hi "..args)
  end
end)

plugin:command("help|commands", function(e, channel, nick, args)
  bot:msg(channel, "Commands: hi, join, part, quit")
end)

plugin:command("error", function(e, channel, nick, args)
  assert(bubbles)
end)

plugin:command("reload", function(e, channel, nick, args)
  bot:msg(channel, "Reloading plugins.")
  bot:set_delayed_func(function() bot.plugin_manager:reload() end)
end)

plugin:command("quit", function(e, channel, nick, args)
  bot:msg(channel, "Sorry, I don't have a way to do that yet.")
end)

plugin:command("join", function(e, channel, nick, args)
  if not args then
    bot:msg(channel, "Which channel?")
  else
    local first = unpack(string.split(args, " ", 1))
    bot:join(first)
    bot:msg(channel, "Ok.")
  end
end)

plugin:command("part", function(e, channel, nick, args)
  if not args then
    bot:msg(channel, "Which channel?")
  else
    local first = unpack(string.split(args, " ", 1))
    if bot:part(first) then
      bot:msg(channel, "Ok.")
    else
      bot:msg(channel, "I can't leave a channel I'm not in.")
    end
  end
end)

return {}