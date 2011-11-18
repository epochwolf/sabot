plugin.name = "Reload"
plugin.version = {0, 0, 1}
plugin.author = "epochwolf"
plugin.description = "Handles reloading plugins."

plugin:command("whoami", function(e, channel, nick, args)
  if bot:nick_is_admin(nick) then 
    api:msg(channel, "You are my admin.")
  elseif nick == "jeannicolas" then
    api:msg(channel, "I shall call you Molly.")
    api:action(channel, "hands "..nick.." a unicycle.")
  else
    api:msg(channel, "You are "..nick..".")
  end
end)

plugin:command("reload", function(e, channel, nick, args)  
  if not bot:nick_is_admin(nick) then 
    api:msg(channel, "I can't do that "..nick..".")
    do return end
  end
  api:msg(channel, "Reloading plugins.")
  bot:set_delayed_func(function() 
    xpcall(
      function()
        bot.plugin_manager:reload()
      end, 
      function(err)
        api:msg(channel, "I couldn't reload my plugins, please check the console.")
        console.error(err)
      end
    )
  end)
end)