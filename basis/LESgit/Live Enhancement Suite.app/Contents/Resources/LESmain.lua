-- beta 13
homepath = os.getenv("HOME")
version = "beta 13"
_G.stricttimevar = true
if console then console:close() end

function folder()
  os.execute("open ~/.hammerspoon/")
end

function testfirstrun()
  local filepath = homepath .. "/.hammerspoon/resources/firstrun.txt"
  local f=io.open(filepath,"r")
  if f~=nil then 
    io.close(f) 
    return true
  else
    return false 
  end
end

if testfirstrun() == false then
  print("This is the first time running LES")

  function setautoadd(newval)
    local hFile = io.open(homepath .. "/.hammerspoon/settings.ini", "r") --Reading.
    local restOfFile
    local lineCt = 1
    local newline = "addtostartup = " .. newval .. [[]]
    local lines = {}
    for line in hFile:lines() do
      if string.find(line, "addtostartup =") then --Is this the line to modify?
        -- print(newline)
        lines[#lines + 1] = newline --Change old line into new line.
        restOfFile = hFile:read("*a")
        break
      else
        lineCt = lineCt + 1
        lines[#lines + 1] = line
      end
    end
    hFile:close()

    hFile = io.open(homepath .. "/.hammerspoon/settings.ini", "w") --write the file.
    for i, line in ipairs(lines) do
      hFile:write(line, "\n")
    end
    hFile:write(restOfFile)
    hFile:close()
  end

  os.execute("mkdir -p ~/.hammerspoon/resources")
  os.execute("echo '' >~/.hammerspoon/resources/firstrun.txt") -- making sure this doesn't trigger twice

  os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/settings.ini ~/.hammerspoon/]])
  os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/menuconfig.ini ~/.hammerspoon/]])
  os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/Resources/readmejingle.wav ~/.hammerspoon/resources/]])

  b, t, o = hs.osascript.applescript([[tell application "System Events" to display dialog "You're all set! Would you like to set LES to launch on login? (this can changed later)" buttons {"Yes", "No"} default button "No" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  print(o)
  b = nil
  t = nil
  if o == [[{ 'bhit':'utxt'("Yes") }]] then
    setautoadd(1)
  elseif o == [[{ 'bhit':'utxt'("No") }]] then
    setautoadd(0)
  end-- first startup routine
end

function testcurrentversion(ver) -- update routine

  print("testing for: " .. ver)
  local filepath = (homepath .. "/.hammerspoon/resources/version.txt")
  local boi = io.open(filepath, "r")

  if boi ~= nil then
    local versionarr = {}

    for line in boi:lines() do
      table.insert (versionarr, line);
    end

    for i=1, 1, 1 do
      if string.match(versionarr[i], ver) then
        return true
      else
        return false
      end
    end
    io.close(boi)
    return false

  else 
    os.execute("echo 'beta 9' >~/.hammerspoon/resources/version.txt")
    return true
  end

end

if testcurrentversion("beta 9") == false and testfirstrun() == true then
  hs.notify.show("Live Enhancement Suite", "Updating and restarting...", "Old installation detected")
  local var = hs.osascript.applescript([[delay 2]])
  if var == true then
    os.execute("rm ~/.hammerspoon/resources/version.txt")
    os.execute("echo 'beta 9' >~/.hammerspoon/resources/version.txt")
    os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/Resources/init.lua ~/.hammerspoon/]])
    hs.alert.show("Restarting..")
    hs.osascript.applescript([[delay 2]])
    hs.reload()
  end
end

function testsettings()
  local filepath = homepath .. "/.hammerspoon/settings.ini"
  local f=io.open(filepath,"r")
  local var = nil
  if f~=nil then 
    io.close(f) 
    var = true 
  else 
    var = false 
  end

  if var == false then
    b, t, o = hs.osascript.applescript([[tell application "System Events" to display dialog "Your settings.ini is missing or corrupt." & return & "Do you want to restore the default settings?" buttons {"Yes", "No"} default button "Yes" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
    print(o)
    b = nil
    t = nil
    if o == [[{ 'bhit':'utxt'("Yes") }]] then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/settings.ini ~/.hammerspoon/]])
    elseif o == [[{ 'bhit':'utxt'("No") }]] then
      os.exit()
    end
    o = nil
  end
end

function testmenuconfig()
  local filepath = homepath .. "/.hammerspoon/menuconfig.ini"
  local f=io.open(filepath,"r")
  local var = nil
  if f~=nil then 
    io.close(f) 
    var = true 
  else 
    var = false 
  end

  if var == false then
    b, t, o = hs.osascript.applescript([[tell application "System Events" to display dialog "Your menuconfig.ini is missing or corrupt." & return & "Do you want to restore the default menuconfig?" buttons {"Yes", "No"} default button "Yes" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
    print(o)
    b = nil
    t = nil
    if o == [[{ 'bhit':'utxt'("Yes") }]] then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/menuconfig.ini ~/.hammerspoon/]])
    elseif o == [[{ 'bhit':'utxt'("No") }]] then
      os.exit()
    end
    o = nil
  end
end

menubarwithdebugoff = {
    { title = "Configure Menu", fn = function() hs.osascript.applescript([[do shell script "open ~/.hammerspoon/menuconfig.ini -a textedit"]]) end },
    { title = "Configure Settings", fn = function() hs.osascript.applescript([[do shell script "open ~/.hammerspoon/settings.ini -a textedit"]]) end },
    { title = "-" },  
    { title = "Donate", fn = function() hs.osascript.applescript([[open location "https://www.paypal.me/enhancementsuite"]]) end },
    { title = "-" },  
    { title = "Project Time", fn = function() requesttime() end },
    { title = "Strict Time", state = "on", fn = function() setstricttime() end },
    { title = "-" },  
    { title = "Reload", fn = function() reloadLES() end },
    { title = "Website", fn = function() hs.osascript.applescript([[open location "https://enhancementsuite.me"]]) end },
    { title = "Manual", fn = function() hs.osascript.applescript([[open location "https://docs.enhancementsuite.me"]]) end },
    { title = "Exit", fn = function() if trackname then ; coolfunc() ; end ; os.exit() end }
}

menubartabledebugon = {
    { title = "Console", fn = function() hs.openConsole(true) end },
    { title = "Restart", fn = function() if trackname then ; coolfunc() ; end ; hs.reload() end },
    { title = "Open Hammerspoon Folder", fn = function() hs.osascript.applescript([[do shell script "open ~/.hammerspoon/ -a Finder"]]) end },
    { title = "-" },
    { title = "Configure Menu", fn = function() hs.osascript.applescript([[do shell script "open ~/.hammerspoon/menuconfig.ini -a textedit"]]) end },
    { title = "Configure Settings", fn = function() hs.osascript.applescript([[do shell script "open ~/.hammerspoon/settings.ini -a textedit"]]) end },
    { title = "-" },  
    { title = "Donate", fn = function() hs.osascript.applescript([[open location "https://www.paypal.me/enhancementsuite"]]) end },
    { title = "-" },  
    { title = "Project Time", fn = function() requesttime() end },
    { title = "Strict Time", state = "on", fn = function() setstricttime() end },
    { title = "-" },  
    { title = "Reload", fn = function() reloadLES() end },
    { title = "Website", fn = function() hs.osascript.applescript([[open location "https://enhancementsuite.me"]]) end },
    { title = "Manual", fn = function() hs.osascript.applescript([[open location "https://docs.enhancementsuite.me"]]) end },
    { title = "Exit", fn = function() if trackname then ; coolfunc() ; end ; os.exit() end }
}

menu2 = {
  { menu = { { title = "Major/Ionian", fn = function() _G.stampselect = "Major" end },
  { title = "Natural Minor/Aeolean", fn = function() _G.stampselect = "Minor" end },
  { title = "Harmonic Minor", fn = function() _G.stampselect = "MinorH" end },
  { title = "Melodic Minor", fn = function() _G.stampselect = "MinorM" end },
  { title = "Dorian", fn = function() _G.stampselect = "Dorian" end },
  { title = "Phrygian", fn = function() _G.stampselect = "Phrygian" end },
  { title = "Lydian", fn = function() _G.stampselect = "Lydian" end },
  { title = "Mixolydian", fn = function() _G.stampselect = "Mixolydian" end },
  { title = "Locrean", fn = function() _G.stampselect = "Locrean" end },
  { title = "-" },

  { menu = { { title = "Major Pentatonic", fn = function() _G.stampselect = "MajorPentatonic" end },
  { title = "Minor Pentatonic", fn = function() _G.stampselect = "Blues" end },
  { title = "Major Blues", fn = function() _G.stampselect = "BluesMaj" end },
  { title = "Minor Blues", fn = function() _G.stampselect = "Blues" end } }, title = "Pentatonic Based" },

  { menu = { { title = "Gypsy", fn = function() _G.stampselect = "Gypsy" end },
  { title = "Minor Gypsy", fn = function() _G.stampselect = "GypsyM" end },
  { title = "Arabic/Double Harmonic", fn = function() _G.stampselect = "Arabic" end },
  { title = "Hungarian Minor", fn = function() _G.stampselect = "HungarianM" end },
  { title = "Pelog", fn = function() _G.stampselect = "Pelog" end },
  { title = "Bhairav", fn = function() _G.stampselect = "Bhairav" end },
  { title = "Spanish", fn = function() _G.stampselect = "Spanish" end },
  { title = "-" },
  { title = "Hirajōshi", fn = function() _G.stampselect = "Hirajoshi" end },
  { title = "In-Sen", fn = function() _G.stampselect = "Insen" end },
  { title = "Iwato", fn = function() _G.stampselect = "Iwato" end }, 
  { title = "Kumoi", fn = function() _G.stampselect = "Kumoi" end } }, title = "World" },

  { menu = { { title = "Chromatic/Freeform Jazz", fn = function() _G.stampselect = "Chromatic" end },
  { title = "Wholetone", fn = function() _G.stampselect = "Wholetone" end },
  { title = "Diminished", fn = function() _G.stampselect = "Diminished" end },
  { title = "Dominant Bebop", fn = function() _G.stampselect = "Dominantbebop" end },
  { title = "Super Locrian", fn = function() _G.stampselect = "Superlocrian" end } }, title = "Chromatic" } }, title = "Scales" },

  { menu = { { title = "Octaves", fn = function() _G.stampselect = "Octaves" end },
  { title = "Power Chord", fn = function() _G.stampselect = "Powerchord" end },
  { title = "-" },
  { title = "Major", fn = function() _G.stampselect = "Maj" end },
  { title = "Minor", fn = function() _G.stampselect = "Min" end },
  { title = "Maj7", fn = function() _G.stampselect = "Maj7" end },
  { title = "Min7", fn = function() _G.stampselect = "Min7" end },
  { title = "Maj9", fn = function() _G.stampselect = "Maj9" end },
  { title = "Min9", fn = function() _G.stampselect = "Min9" end },
  { title = "7", fn = function() _G.stampselect = "Dom7" end },
  { title = "Augmented", fn = function() _G.stampselect = "Aug" end },
  { title = "Diminished", fn = function() _G.stampselect = "Dim" end },
  { title = "-" },
  { title = "Triad (Fold)", fn = function() _G.stampselect = "Fold3" end },
  { title = "Seventh (Fold)", fn = function() _G.stampselect = "Fold7" end },
  { title = "Ninth (Fold)", fn = function() _G.stampselect = "Fold9" end } }, title = "Chords" },
}

function readme()
  local readmejingleobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/readmejingle.wav")
  readmejingleobj:device(nil)
  readmejingleobj:loopSound(false)
  readmejingleobj:play()
  local bigboyvar = hs.osascript.applescript([[tell application "Live Enhancement Suite" to display dialog "Welcome to the Live Enhancement Suite MacOS rewrite created by @InvertedSilence, @DirectOfficial, with an installer by @actuallyjamez 🐦" & return & "Double right click to open up the custom plug-in menu." & return & "Click on the LES logo in the menu bar to add your own plug-ins, change settings, and read our manual." & return & "Happy producing : )" buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite"]])
  readmejingleobj = nil
  bigboyvar = nil
end

function buildPluginMenu()

  file = io.open("menuconfig.ini", "r") 
  local arr = {}
    for line in file:lines() do
      table.insert (arr, line);
    end

  if pluginArray ~= nil then
    delcount = #pluginArray -- delete array
    for i=0, delcount do pluginArray[i]=nil end
  end
  if menu ~= nil then
    delcount = #menu -- delete array
    for i=0, delcount do menu[i]=nil end
  end

  -- Reverses the Array. This could be done inline
  -- but I made it a helper function just in case.
  -- -- Direct
  function Reverse (arr)
    local i, j = 1, #arr

    while i < j do
      arr[i], arr[j] = arr[j], arr[i]

      i = i + 1
      j = j - 1
    end
  end
  -- Reverse the order of the array. 
  print(hs.inspect(arr))
  Reverse(arr)

  readmevar = false

  for i = #arr, 1, - 1
    do
    if arr[i] == "—\r" or arr[i] == "-\n"  or arr[i] == "-" then
      table.insert(arr, i, "--")
    elseif string.len(arr[i]) < 2 
      then
      table.remove(arr, i)
    elseif arr[i] == nil then
      table.remove(arr, i)
    elseif string.find(arr[i], ";") == 1 then
      table.remove(arr, i)
    elseif string.match(arr[i], "Readme") or string.match(arr[i], "readme") then
      readmevar = true -- I decided to just have the readme always stick on the bottom since it was easier to program and nobody cares anyway :^)
      table.remove(arr, i)
    elseif string.find(arr[i], "%-%-") == 1 then 
      table.insert(arr, i, "--")
    elseif string.find(arr[i], "End") then
      table.remove(arr, i)
    elseif string.find(arr[i], "") then
    end
  end

  local subfolderval = 0
  local subfoldername = ""
  local subfolderuponelevel = ""
  subfolderhistory = {}
  pluginArray = {}

  for i = #arr, 1, - 1 do
    if string.find(string.sub(arr[i],1 ,1), "/") and not string.find(string.sub(arr[i],1 ,2), "//") and not string.find(arr[i], "nocategory") then
      subfoldername = string.gsub(arr[i],'','')
      table.insert(subfolderhistory, subfoldername)
      subfolderval = 1
      table.remove(arr, i)
    elseif string.find(string.sub(arr[i],1,2), "//") then
      table.insert(subfolderhistory, subfoldername)
      subfoldername = string.gsub(arr[i],'','')
      local _, count = string.gsub(arr[i], "%/", "")
      subfolderval = count
      string = subfolderval .. ", " .. subfoldername.. ", " .. "◶"
      table.insert(pluginArray, string)
      table.insert(pluginArray, string)
      table.remove(arr, i)
    elseif string.find(string.sub(arr[i],1 ,2), "%.%.") then
      subfoldername = subfolderhistory[subfolderval]
      subfolderval = subfolderval - 1
      --table.remove(arr, i)
      -- table.insert(arr[i])
    elseif string.find(arr[i], "/nocategory") then
      subfolderval = 0
      table.remove(arr, i)
    else
      string = subfolderval .. ", " .. subfoldername.. ", " .. arr[i]
      table.insert(pluginArray, string)
    end
  end

  print("------pluginarray-----")
  print(hs.inspect(pluginArray))
  print("------subfolderhistory-----")
  print(hs.inspect(subfolderhistory))

  function mysplit(inputstr)
    local t={} ; i=1
    if inputstr == nil then
      return
    end
    for str in string.gmatch(inputstr, "([^,]+)") do
            t[i] = str
            i = i + 1
    end
    return t
  end

  -- for i = 1, #arr do
  --   print(pluginArray[i])
  -- end

  function RemoveSlashes(string, scope)
    newstring = string:gsub("^%s*(.-)%s*$", "%1")
    newstring = string.sub(newstring, scope + 1)
    return newstring
  end

  local lastLevel = 0
  local level = 0
  lastcatagoryName = "menu"
  scopes = {}

  for i = 1, #pluginArray, 2 do
    if pluginArray[i] == nil then
      table.remove(pluginArray, i)
      goto pls
    end
    if pluginArray[i + 1] == nil then
      table.remove(pluginArray, (i + 1))
      goto pls
    end
    local level = tonumber(string.sub(pluginArray[i], 1, 1))

    local thisIndex = mysplit(pluginArray[i])
    local nextIndex = mysplit(pluginArray[i + 1])
    local categoryName = RemoveSlashes(thisIndex[2], level)

    -- This only runs at the start of the loop and sets up
    -- the first menu. You need to have this as a global scope
    -- so you can address it with a dynamic name.
    if i == 1 and level == 0 then
      if _G[lastcatagoryName] == nil then
        _G[lastcatagoryName] = {}
      end
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[lastcatagoryName], { title = "-" })
      else
        table.insert(_G[lastcatagoryName], {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts the first plugin
        print("strt. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])
      end

    elseif i == 1 and level == 1 then
      if _G[lastcatagoryName] == nil then
        _G[lastcatagoryName] = {}
      end
      print("upst. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])

      _G[categoryName] = {{title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }}

      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[lastcatagoryName], { title = "-" })
      else
        table.insert(_G[lastcatagoryName], {title = categoryName, menu = _G[categoryName]})
        -- table.insert(_G[lastcatagoryName], {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts the first plugin
      end
      table.insert(scopes, lastcatagoryName)
    -- This is only for when we return home.
    elseif level == 0 then

      if string.find(pluginArray[i], "%-%-") then
        table.insert(menu, { title = "-" })
      else
        table.insert(menu, {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts the first plugin
        print("zero. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])
      end

    -- Up scope
    elseif level > lastLevel then
      print("uppp. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])

      -- if string.match(nextIndex[3], "Readme") 
      print(nextIndex[3])
      if string.match(nextIndex[3], " ◶") ~= nil then
        _G[categoryName] = {}
      else
        _G[categoryName] = {{title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }}
      end
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[lastcatagoryName], { title = "-" })
      else
        table.insert(_G[lastcatagoryName], {title = categoryName, menu = _G[categoryName]}) -- Inserts the new menu
      end
      table.insert(scopes, lastcatagoryName)

    -- Same scope
    elseif level == lastLevel and categoryName == lastcatagoryName then

      print("same. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[categoryName], { title = "-" })
      else
        table.insert(_G[categoryName], {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts plugin 
      end

    -- Same scope new folder
    elseif level == lastLevel and categoryName ~= lastcatagoryName then
      print("scopes: " .. scopes[level])

      if _G[categoryName] == nil then
        _G[categoryName] = {}
      end
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[scopes[level]], { title = "-" })
      else
        _G[categoryName] = {{title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }}
        table.insert(_G[scopes[level]], {title = categoryName, menu = _G[categoryName]}) -- Inserts the new menu
      end
      print("nfnf. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])

      -- Down scope with new folder
    elseif level < lastLevel and categoryName ~= lastcatagoryName then
      print("down scope. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])
      if _G[categoryName] == nil then
        _G[categoryName] = {}
       table.insert(_G[scopes[level]], {title = categoryName, menu = _G[categoryName]}) -- Inserts the new menu
        
      end
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[categoryName], { title = "-" })
      else
       table.insert(_G[categoryName], {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts plugin
      end

    -- Down scope -- this was needed in some particular cases lol @direct pls
    elseif level < lastLevel and categoryName == lastcatagoryName then
      print("down scope. current scope: " .. categoryName .. " level: " .. level .. "item: " .. nextIndex[3])
      if _G[categoryName] == nil then
        _G[categoryName] = {}
      end
      if string.find(pluginArray[i], "%-%-") then
        table.insert(_G[categoryName], { title = "-" })
      else
        table.insert(_G[categoryName], {title = string.sub(thisIndex[3],2), fn = function() loadPlugin(nextIndex[3]) end }) -- inserts plugin
      end
    end
    lastLevel = level
    -- this conditional basically checks if we are 'home' and if we are
    -- then we last category = menu.
    if categorycount == nil then
      categorycount = 0 -- 0 because the count is increased to 1 by the first item causing the first entry to be nil
      categoryhistory = {}
    end


    if lastLevel == 0 then
      lastcatagoryName = "menu"
    else
      if lastcatagoryName ~= nil then
        if lastcatagoryName ~= categoryName then
          categorycount = (categorycount + 1) 
        end
      end
      lastcatagoryName = categoryName
      categoryhistory[categorycount] = lastcatagoryName
    end

    ::pls::
  end

  if readmevar == true then
    -- table.insert(menu, {title = "-"})
    table.insert(menu, {title = "read me", fn = function() readme() end })
  end

  categoryName = nil
  lastcatagoryName = nil
  lastlevel = nil
  level = nil
  scope = nil
  categorycount = nil
end

function clearcategories() -- clears all the categories from ram
	if categoryhistory ~= nil then
		print("category history exists")
		for i = 1, #categoryhistory, 1 do
			_G[categoryhistory[i]] = nil
		end
		categoryhistory = nil
	end
end

function settingserrorbinary(message, range)
  if hs.osascript.applescript([[tell application "System Events" to display dialog "Error found in settings.ini" & return & "Value for \"]] .. message .. [[\" is not ]] .. range .. [[." buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]]) then os.execute("open ~/.hammerspoon/settings.ini -a textedit") ; os.exit() end
end

function buildSettings()
  if settingsArray ~= nil then
    delcount = #settingsArray -- delete array
    for i=0, delcount do 
      settingsArray[i]=nil 
    end
  end

  settings = io.open("settings.ini", "r")
  settingsArray = {}
  for line in settings:lines() do
     table.insert (settingsArray, line)
  end
  -- print(hs.inspect(settingsArray))

  for i = 1, #settingsArray, 1 do
  ::loopstart::
  if i > #settingsArray then break end

    if settingsArray[i] == nil then
      table.remove(settingsArray, i)
    elseif string.find(settingsArray[i], ";") == 1 then
      -- print("line " .. i .. " this is a comment -- " .. settingsArray[i])
      table.remove(settingsArray, i)
      i = i + 1
      goto loopstart
    elseif string.find(settingsArray[i], "End") then
      table.remove(settingsArray, i)
      i = i + 1
      goto loopstart
    end

    if string.find(settingsArray[i], "autoadd =") then
      print("autoadd found")
      _G.autoadd = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.autoadd, "%D") then
        settingserrorbinary("autoadd", "a number between 0 and 1")
      end
      _G.autoadd = tonumber(_G.autoadd)
      if _G.autoadd > 1 or _G.autoadd < 0 then
        settingserrorbinary("autoadd", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "loadspeed =") then
      print("loadspeed found")
      _G.loadspeed = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.find(_G.loadspeed, "%D%.") then
        settingserrorbinary("loadspeed", "a number")
      end
      _G.loadspeed = tonumber(_G.loadspeed)
      if _G.loadspeed < 0 then
        settingserrorbinary("loadspeed", "a number higher than 0")
      end
    end

    if string.find(settingsArray[i], "resettobrowserbookmark =") then
      print("resettobrowserbookmark found")
      _G.resettobrowserbookmark = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.find(_G.resettobrowserbookmark, "%D%.") then
        settingserrorbinary("resettobrowserbookmark", "a number")
      end
      _G.resettobrowserbookmark = tonumber(_G.resettobrowserbookmark)
      if _G.resettobrowserbookmark < 0 then
        settingserrorbinary("resettobrowserbookmark", "a number higher than 0")
      end
    end

    if string.find(settingsArray[i], "bookmarkx =") then
    	_G.bookmarkx = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      print("bookmarkx found")
      if string.find(_G.bookmarkx, "%D%.") then
        settingserrorbinary("bookmarkx", "a number")
      end
      _G.bookmarkx = tonumber(_G.bookmarkx)
      if _G.bookmarkx < 0 then
        settingserrorbinary("bookmarkx", "a number higher than 0")
      end
    end

    if string.find(settingsArray[i], "bookmarky =") then
    	_G.bookmarky = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      print("bookmarky found")
      if string.find(_G.bookmarky, "%D%.") then
        settingserrorbinary("bookmarky", "a number")
      end
      _G.bookmarky = tonumber(_G.bookmarky)
      if _G.bookmarky < 0 then
        settingserrorbinary("bookmarky", "a number higher than 0")
      end
    end

    if string.find(settingsArray[i], "disableloop =") then
      print("disableloop found")
      _G.disableloop = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.disableloop, "%D") then
        settingserrorbinary("disableloop", "a number between 0 and 1")
      end
      _G.disableloop = tonumber(_G.disableloop)
      if _G.disableloop > 1 or _G.disableloop < 0 then
        settingserrorbinary("disableloop", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "saveasnewver =") then
      print("saveasnewver found")
      _G.saveasnewver = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.saveasnewver, "%D") then
        settingserrorbinary("saveasnewver", "a number between 0 and 1")
      end
      _G.saveasnewver = tonumber(_G.saveasnewver)
      if _G.saveasnewver > 1 or _G.saveasnewver < 0 then
        settingserrorbinary("saveasnewver", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "altgrmarker =") then
      print("altgrmarker found")
      _G.altgrmarker = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.altgrmarker, "%D") then
        settingserrorbinary("altgrmarker", "a number between 0 and 1")
      end
      _G.altgrmarker = tonumber(_G.altgrmarker)
      if _G.altgrmarker > 1 or _G.altgrmarker < 0 then
        settingserrorbinary("altgrmarker", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "double0todelete =") then
      print("double0todelete found")
      _G.double0todelete = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.double0todelete, "%D") then
        settingserrorbinary("double0todelete", "a number between 0 and 1")
      end
      _G.double0todelete = tonumber(_G.double0todelete)
      msgboxscript = [[display dialog "]] .. _G.double0todelete .. [[" buttons {"ok"} default button "ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]]
      if _G.double0todelete > 1 or _G.double0todelete < 0 then
        settingserrorbinary("double0todelete", "a number between 0 and 1")
      end
    end  

    if string.find(settingsArray[i], "ctrlabsoluteduplicate =") then
      print("ctrlabsoluteduplicate found")
      _G.ctrlabsoluteduplicate = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.ctrlabsoluteduplicate, "%D") then
        settingserrorbinary("ctrlabsoluteduplicate", "a number between 0 and 1")
      end
      _G.ctrlabsoluteduplicate = tonumber(_G.ctrlabsoluteduplicate)
      if _G.ctrlabsoluteduplicate > 1 or _G.ctrlabsoluteduplicate < 0 then
        settingserrorbinary("ctrlabsoluteduplicate", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "pianorollmacro =") then
      print("pianorollmacro found")
      if hs.keycodes.map[settingsArray[i]:gsub(".*(.*)%=%s","%1")] == nil then
        settingserrorbinary("pianorollmacro", "a character corresponding to a key on your keyboard")
      end
      _G.pianorollmacro = hs.keycodes.map[settingsArray[i]:gsub(".*(.*)%=%s","%1")]
    end

    if string.find(settingsArray[i], "dynamicreload =") then
      print("dynamicreload found")
      _G.dynamicreload = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.dynamicreload, "%D") then
        settingserrorbinary("dynamicreload", "a number between 0 and 1")
      end
      _G.dynamicreload = tonumber(_G.dynamicreload)
      if _G.dynamicreload > 1 or _G.dynamicreload < 0 then
        settingserrorbinary("dynamicreload", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "enabledebug =") then
      print("enabledebug found")
      _G.enabledebug = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.enabledebug, "%D") then
        settingserrorbinary("enabledebug", "a number between 0 and 1")
      end
      _G.enabledebug = tonumber(_G.enabledebug)
      if _G.enabledebug > 1 or _G.enabledebug < 0 then
        settingserrorbinary("enabledebug", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "texticon =") then
      print("texticon found")
      _G.texticon = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.texticon, "%D") then
        settingserrorbinary("texticon", "a number between 0 and 1")
      end
      _G.texticon = tonumber(_G.texticon)
      if _G.texticon > 1 or _G.texticon < 0 then
        settingserrorbinary("texticon", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "addtostartup =") then
      print("addtostartup found")
      _G.addtostartup = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.addtostartup, "%D") then
        settingserrorbinary("addtostartup", "a number between 0 and 1")
      end
      _G.addtostartup = tonumber(_G.addtostartup)
      if _G.addtostartup > 1 or _G.addtostartup < 0 then
        settingserrorbinary("addtostartup", "a number between 0 and 1")
      end
    end

    if string.find(settingsArray[i], "enabledebug =") then
      print("enabledebug found")
      _G.enabledebug = settingsArray[i]:gsub(".*(.*)%=%s","%1")
      if string.match(_G.enabledebug, "%D") then
        settingserrorbinary("enabledebug", "a number between 0 and 1")
      end
      _G.enabledebug = tonumber(_G.enabledebug)
      if _G.enabledebug > 1 or _G.enabledebug < 0 then
        settingserrorbinary("enabledebug", "a number between 0 and 1")
      end
    end
  end
end

function buildMenuBar()
  if LESmenubar ~= nil then
    LESmenubar:delete()
  end
  if _G.enabledebug == 1 then 
      menubartable = menubartabledebugon
  else
      menubartable = menubarwithdebugoff
  end
  LESmenubar = hs.menubar.new()
  LESmenubar:setMenu(menubartable)
  if _G.texticon == 1 then
    LESmenubar:setTitle("LES")
  else
    LESmenubar:setIcon("/Applications/Live Enhancement Suite.app/Contents/Resources/osxTrayIcon.png", true)
  end
end

function rebuildRcMenu()
  if pluginMenu ~= nil then
    pluginMenu:delete()
  end
  pluginMenu = hs.menubar.new()
  pluginMenu:setMenu(menu)
  pluginMenu:setTitle("LES")
  pluginMenu:removeFromMenuBar()

  if pianoMenu ~= nil then
    pianoMenu:delete()
  end
  pianoMenu = hs.menubar.new()
  pianoMenu:setMenu(menu2)
  pianoMenu:setTitle("Piano")
  pianoMenu:removeFromMenuBar()
end

function cheats()
  if _G.enabledebug == 1 then
    down1, down2 = false, true
    dingodango = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown }, function(e)
      local flag = e:rawFlags()
      -- print(flag)
      if flag == 131334 and down1 == false and down2 == true then
        print("doubleshift press 1")
        press1 = hs.timer.secondsSinceEpoch()
        down1 = true
        down2 = false
        if press2 ~= nil then
          if (press1 - press2) < 0.2 then 
            cheatmenu()
         end
        end
      elseif flag == 131334 and down1 == true and down2 == false then
        print("doubleshift press 2")
        press2 = hs.timer.secondsSinceEpoch()
        down1 = false
        down2 = true
        if (press2 - press1) < 0.2 then 
          cheatmenu()
        end
      end
    end):start()
  else
    if dingodango then
      dingodango:stop()
    end
  end
end

function reloadLES()
  clearcategories()
  if pluginMenu then
    pluginMenu = nil
  end
  if pianoMenu then
    pianoMenu = nil
  end
  testmenuconfig()
  testsettings()
  buildSettings()
  buildPluginMenu()
  buildMenuBar()
  rebuildRcMenu()
  if _G.addtostartup == 1 then
    print("startup = true")
    hs.autoLaunch(true)
    os.execute([[launchctl load /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/live.enhancement.suite.plist]])
  else
    print("startup = false")
    hs.autoLaunch(false)
    os.execute([[launchctl unload /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/live.enhancement.suite.plist]])
  end
  -- pluginMenu:removeFromMenuBar() -- somehow if stuff doesn't properly get removed
  -- pianoMenu:removeFromMenuBar()
  cheats()
end

function quickreload()
  clearcategories()
  if pluginMenu then
    pluginMenu = nil
  end
  if pianoMenu then
    pianoMenu = nil
  end
  testmenuconfig()
  buildPluginMenu()
  rebuildRcMenu()
end

reloadLES() -- this function calls all the config stuff and reloads all the menus and variables nicely

-- This is my current fallback because I cannot seem to get
-- the double right clicking working properly. - Direct
hyper = {"ctrl", "alt", "cmd", "shift"}
directshyper = hs.hotkey.bind(hyper, "H", function()
  spawnPluginMenu()
end)

hyper3 = {"cmd", "alt"}
hs.hotkey.bind(hyper3, "S", function()
end)

-- since eventtap.events seems to use quite a bit of CPU on lower end models, 
-- I've decided to try and condense a bunch of such shortcuts into this section:
-- the pro of this approach is, unlike hs.hotkey, that it sends the original input still.
-- it also allows you to trigger actions on the key down event which is nice. 

_G.debounce = false
down12, down22 = false, true

_G.quickmacro = hs.eventtap.new({ 
  hs.eventtap.event.types.keyDown,
  hs.eventtap.event.types.keyUp,
  hs.eventtap.event.types.leftMouseDown,
  hs.eventtap.event.types.leftMouseUp,
}, function(event)
    local keycode = event:getKeyCode()
    local mousestate = event:getButtonState(0)
    local eventtype = event:getType()
    local clickState = hs.eventtap.event.properties.mouseEventClickState

    backspacekk = hs.keycodes.map["delete"]

    -- macro for automatically disabling loop on clips
    if _G.disableloop == 1 then
      if keycode == hs.keycodes.map["M"] and hs.eventtap.checkKeyboardModifiers().shift and hs.eventtap.checkKeyboardModifiers().cmd then
          local hyper2 = {"cmd", "shfit"}
          hs.eventtap.keyStroke(hyper2, "J")
      end
    end

    -- envelope mode macro
    if keycode == hs.keycodes.map["E"] and hs.eventtap.checkKeyboardModifiers().alt then
      _G.dimensions = hs.application.find("Live"):mainWindow():frame()
      -- print("top left: " .. _G.dimensions.x .. " & " .. _G.dimensions.y)
      -- print("top right: " .. (_G.dimensions.x + _G.dimensions.w) .. " & " .. _G.dimensions.y)
      -- print("bottom left: " .. _G.dimensions.x .. " & " .. (_G.dimensions.y + _G.dimensions.h))

      local prepoint = {}
      prepoint = hs.mouse.getAbsolutePosition()
      prepoint["__luaSkinType"] = nil

      local coolvar5 = (_G.dimensions.x + 43)
      local coolvar4 = (_G.dimensions.y + _G.dimensions.h - 37)

      local postpoint = {}
      postpoint["x"] = coolvar5
      postpoint["y"] = coolvar4
      for i = 1, 5, 1 do
        hs.eventtap.leftClick(postpoint, 0)
        postpoint["x"] = postpoint["x"] + 18
        postpoint["y"] = postpoint["y"] - 18
        -- print(hs.inspect(postpoint))
      end
      postpoint["x"] = (_G.dimensions.x + 51)
      postpoint["y"] = (_G.dimensions.y + _G.dimensions.h - 47)
      hs.eventtap.leftClick(postpoint, 0)
      hs.mouse.setAbsolutePosition(prepoint)
      -- print(hs.inspect("prepoint: " .. prepoint))
    end

    -- save as new version
    if _G.saveasnewver == 1 then
      if keycode == hs.keycodes.map["S"] and hs.eventtap.checkKeyboardModifiers().alt and hs.eventtap.checkKeyboardModifiers().cmd then
        -- print(_G.debounce)
        -- hs.alert.show(debounce)
        if _G.debounce == false then
          _G.debounce = true
          local hyper2 = {"cmd", "shift"}
          local mainwindowname = hs.application.find("Live"):mainWindow():title()
          -- print(mainwindowname)
          local projectname = (mainwindowname:gsub("%s%s%[.*", "")) -- use Gsub to get project name from main window title
          local newname = nil

          if projectname == "Untitled" and o == nil then -- dialog box that warns you when you save as new version on an untitled project
            local b, t, o = hs.osascript.applescript([[tell application "Ableton Live 10 Suite" to display dialog "Your project name is \"Untitled\"." & return & "Are you sure you want to save it as a new version?" buttons {"Yes", "No"} default button "No" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
            print(o)
            if o == [[{ 'bhit':'utxt'("No") }]] then
              hs.eventtap.keyStroke(hyper2, "S")
              if hs.osascript.applescript([[delay 2]]) == true then
              debounce = false
              end
              return
            end
          end

          if string.find(projectname, "_%d") then -- does the project already have a version syntax?
            local version = (projectname:gsub(".*(.*)_","%1")) -- remove everything after the last "_"
            local name = (projectname:gsub("(.*)_.*","%1")) -- remove everything prior to the last "_"

            if string.find(version, "%.") and string.find(version, "%a") then -- test if the current version syntax has both a decimal and a letter
              local everythingafterdecimal = version:gsub(".*%.", "") -- process things after decimal and pre decimal 
              everythingafterdecimal = everythingafterdecimal:gsub("%a","1")
              version = version:gsub("%..*", "." .. everythingafterdecimal)
            end

            if string.find(version, "%.") then -- if string has a decimal point, round it up
              newver = math.ceil(version)
            else
              newver = (version + 1)  -- if string doesn't have a decimal point, add 1
              newver = math.floor(newver)
            end
            newname = name .. "_" .. newver
          else
          newname = projectname .. "_2"
          end

          hs.osascript.applescript([[
          tell application "System Events" to tell process "Live"
            ignoring application responses
              click menu item "Save Live Set As..." in menu 1 in menu bar item "File" in menu bar 1
            end ignoring
          end tell
          ]])

          hs.osascript.applescript([[delay 0.18]])

          hs.eventtap.keyStrokes(newname)
          hs.eventtap.keyStroke({}, "return")

          if hs.osascript.applescript([[delay 2.5]]) == true then
            debounce = false
          end
        end
      end
    end

    -- macro for closing currently focussed plugin window
    if keycode == hs.keycodes.map["W"] and hs.eventtap.checkKeyboardModifiers().cmd and not hs.eventtap.checkKeyboardModifiers().alt then
      local mainwindowname = nil
      mainwindowname = hs.application.find("Live"):mainWindow()
      focusedWindow = hs.window.frontmostWindow()
      if mainwindowname ~= focusedWindow then
        focusedWindow:close()
      end
    end

    -- macro for closing all plugin windows
    if keycode == hs.keycodes.map["W"] and hs.eventtap.checkKeyboardModifiers().cmd and hs.eventtap.checkKeyboardModifiers().alt or keycode == hs.keycodes.map["escape"] and hs.eventtap.checkKeyboardModifiers().cmd then
      local allwindows = hs.application.find("Live"):allWindows()
      local mainwindowname = nil
      mainwindowname = hs.application.find("Live"):mainWindow()
      for i = 1, #allwindows, 1 do
        if allwindows[i] ~= mainwindowname then
          allwindows[i]:close()
        end
      end
    end

    -- macro for adding a locator in the playlist
    if altgrmarker == 1 then
      if keycode == hs.keycodes.map["L"] and hs.eventtap.checkKeyboardModifiers().alt then
        print("marker macro pressed")
        hs.osascript.applescript([[
          tell application "Live" to activate
          tell application "System Events" to tell process "Live"
            ignoring application responses
              click menu item "Add Locator" in menu 1 in menu bar item "Create" in menu bar 1
              key code ]] .. backspacekk .. "\n" ..
            [[end ignoring
          end tell
        ]])
      end
    else
      if keycode == hs.keycodes.map["L"] and hs.eventtap.checkKeyboardModifiers().shift then
        print("marker macro pressed")
        hs.osascript.applescript([[
          tell application "Live" to activate
          tell application "System Events" to tell process "Live"
            ignoring application responses
              click menu item "Add Locator" in menu 1 in menu bar item "Create" in menu bar 1
              key code ]] .. backspacekk .. "\n" ..
            [[end ignoring
          end tell
        ]])
      end
    end

    -- Absolute Buplicate
    if ctrlabsoluteduplicate == 1 then
      if keycode == hs.keycodes.map["D"] and hs.eventtap.checkKeyboardModifiers().ctrl and hs.eventtap.checkKeyboardModifiers().cmd and eventtype == hs.eventtap.event.types.keyUp then
        hs.osascript.applescript([[tell application "Live" to activate
          tell application "System Events" to tell process "live"
          ignoring application responses
            click menu item "Copy" in menu 1 in menu bar item "Edit" in menu bar 1
            click menu item "Duplicate" in menu 1 in menu bar item "Edit" in menu bar 1
            key code ]] .. backspacekk .. "\n" ..
            [[click menu item "Paste" in menu 1 in menu bar item "Edit" in menu bar 1
          end ignoring
        end tell]])
      end
    else
      if keycode == hs.keycodes.map["D"] and hs.eventtap.checkKeyboardModifiers().alt and hs.eventtap.checkKeyboardModifiers().cmd and eventtype == hs.eventtap.event.types.keyUp then
        hs.osascript.applescript([[tell application "Live" to activate
          tell application "System Events" to tell process "live"
          ignoring application responses
            click menu item "Copy" in menu 1 in menu bar item "Edit" in menu bar 1
            click menu item "Duplicate" in menu 1 in menu bar item "Edit" in menu bar 1
            key code ]] .. backspacekk .. "\n" ..
            [[click menu item "Paste" in menu 1 in menu bar item "Edit" in menu bar 1
          end ignoring
        end tell]])
      end
    end

    if keycode == hs.keycodes.map["V"] and hs.eventtap.checkKeyboardModifiers().alt and hs.eventtap.checkKeyboardModifiers().cmd and eventtype == hs.eventtap.event.types.keyUp then
      hs.osascript.applescript([[tell application "Live" to activate
        tell application "System Events" to tell process "live"
        ignoring application responses
          click menu item "Paste" in menu 1 in menu bar item "Edit" in menu bar 1
          key code ]] .. backspacekk .. "\n" ..
          [[click menu item "Paste" in menu 1 in menu bar item "Edit" in menu bar 1
        end ignoring
      end tell]])
    end


    if _G.double0todelete == 1 then
      if keycode == hs.keycodes.map["0"] then -- double zero to delete
        if down12 == false and down22 == true then
          press12 = hs.timer.secondsSinceEpoch()
          down12 = true
          down22 = false
          if press22 ~= nil then
            if (press12 - press22) < 0.05 then 
              hs.eventtap.keyStroke({}, hs.keycodes.map["delete"], 0)
              press12 = nil
              press22 = nil
           end
          end
        elseif down12 == true and down22 == false then
          press22 = hs.timer.secondsSinceEpoch()
          down12 = false
          down22 = true
          if press12 ~= nil then
            if (press22 - press12) < 0.05 then 
              hs.eventtap.keyStroke({}, hs.keycodes.map["delete"], 0)
              press12 = nil
              press22 = nil
            end
          end
        end
      end
    end

    if keycode == hs.keycodes.map["X"] and hs.eventtap.checkKeyboardModifiers().alt then -- clear track
      if firstDown ~= nil or secondDown ~= nil then
        timeRMBTime, firstDown, secondDown = nil, nil, nil
      end
      firstRightClick:stop()
      local point = {}
      point = hs.mouse.getAbsolutePosition()
      point["__luaSkinType"] = nil
      hs.eventtap.rightClick(point, 0)

      hs.eventtap.keyStroke({}, "G", 0)
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "return", 0)
      hs.eventtap.keyStroke({}, "delete", 0)
      firstRightClick:start()
    end

    if keycode == hs.keycodes.map["C"] and hs.eventtap.checkKeyboardModifiers().alt then -- colour track
      if firstDown ~= nil or secondDown ~= nil then
        timeRMBTime, firstDown, secondDown = 0, false, true
      end
      firstRightClick:stop()
      local point = {}
      point = hs.mouse.getAbsolutePosition()
      point["__luaSkinType"] = nil
      hs.eventtap.rightClick(point, 0)

      hs.eventtap.keyStroke({}, "up", 0)
      hs.eventtap.keyStroke({}, "up", 0)
      hs.eventtap.keyStroke({}, "return", 0)
      firstRightClick:start()
    end

end):start()

function msgBox(message)
  msgboxscript = [[display dialog "]] .. message .. [[" buttons {"ok"} default button "ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]]
  local b, t, o = hs.osascript.applescript(msgboxscript)
  b = nil
  t = nil
  if o == [[{ 'bhit':'utxt'("ok") }]] then
    return true
  else
    return false
  end
end

function spawnPluginMenu()
  pluginMenu:popupMenu(hs.mouse.getAbsolutePosition())
  
end

function spawnPianoMenu()
  pianoMenu:popupMenu(hs.mouse.getAbsolutePosition())
end

function getABSTime()
  return hs.timer.absoluteTime()
end

function nanoToSec(nanoseconds)
  seconds = nanoseconds*1000000000
  return seconds
end

-- The macOS system menu right click behavior is to open the
-- menu on the mouseDown event. If we trigger our action on
-- that event as well the system menu will delay being opened
-- and essentially store the action until our menu closes. We
-- must trigger our event on the mouse up event. -- Direct

timeRMBTime, firstDown, secondDown = 0, false, true

timeFrame = hs.eventtap.doubleClickInterval()

down13 = false
down23 = true
firstRightClick = hs.eventtap.new({
  hs.eventtap.event.types.rightMouseDown,
  hs.eventtap.event.types.rightMouseUp
}, function(event)

  -- if event:getType() == hs.eventtap.event.types.rightMouseDown then
  --   if down13 == false and down23 == true then
  --     print("rclick 1")
  --     press13 = hs.timer.secondsSinceEpoch()
  --     down13 = true
  --     down23 = false
  --     if press23 ~= nil then
  --       if (press13 - press23) < 0.18 then
  --         if _G.dynamicreload == 1 then
  --           quickreload()
  --         end
  --         if _G.pressingshit == true then
  --           spawnPianoMenu()
  --           return
  --         else
  --           spawnPluginMenu()
  --           return
  --         end
  --       end
  --     end
  --   elseif down13 == true and down23 == false then
  --     print("rclick 2")
  --     press23 = hs.timer.secondsSinceEpoch()
  --     down13 = false
  --     down23 = true
  --     if press13 ~= nil then
  --       if (press23 - press13) < 0.18 then
  --         if _G.dynamicreload == 1 then
  --           quickreload()
  --         end
  --         if _G.pressingshit == true then
  --           spawnPianoMenu()
  --           return
  --         else
  --           spawnPluginMenu()
  --           return
  --         end
  --       end
  --     end
  --   end
  -- end

  -- if event:getType() == hs.eventtap.event.types.rightMouseUp then
      
    if (hs.timer.secondsSinceEpoch() - timeRMBTime) > timeFrame then
      timeRMBTime, firstDown, secondDown = 0, false, true
    end
  if event:getType() == hs.eventtap.event.types.rightMouseUp then
    if firstDown and secondDown then
        if _G.dynamicreload == 1 then
          quickreload()
        end
        if _G.pressingshit == true then
          spawnPianoMenu()
          timeRMBTime, firstDown, secondDown = 0, false, true
        else
          spawnPluginMenu()
          timeRMBTime, firstDown, secondDown = 0, false, true
          return
        end
    elseif not firstDown then
        firstDown = true
        timeRMBTime = hs.timer.secondsSinceEpoch()
        return
    elseif firstDown then
        secondDown = true
        return
    else
        timeRMBTime, firstDown, secondDown = 0, false, true
        return
    end
  end

  return
end):start()


function testLive() -- Function for testing if ur in live (this function is retired and is for ease of development mostly)
  local var = hs.window.focusedWindow()
  if var ~= nil then var = var:application():title() else return end
  -- print(var)
  if string.find(var, "Live") then
    print("Ableton Live Found!")
    return true
  else
    return false
  end
end

function bookmarkfunc()
  local point = {}
	local dimensions = hs.application.find("Live"):mainWindow():frame()
	if hs.application.find("Live"):mainWindow():isFullScreen() == true then
		local bookmark = {}
		bookmark["x"] = _G.bookmarkx + dimensions.x
		bookmark["y"] = _G.bookmarky + dimensions.y
    print("pee")
    point = hs.mouse.getAbsolutePosition()
    point["__luaSkinType"] = nil
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], bookmark):setProperty(hs.eventtap.event.properties.mouseEventClickState, 1):post()
    if _G.loadspeed <= 0.5 then
      sleep2 = hs.osascript.applescript([[delay 0.1]])
    else
      sleep2 = hs.osascript.applescript([[delay 0.3]])
    end
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], bookmark):setProperty(hs.eventtap.event.properties.mouseEventClickState, 1):post()
    hs.mouse.setAbsolutePosition(point)
	end
end

debounce2 = 0
-- the plugin names nead to have any new lines removed
function loadPlugin(plugin)
  pluginCleaned = plugin:match'^%s*(.*%S)' or ''
  hs.eventtap.keyStroke("cmd", "f", 0)
  hs.eventtap.keyStrokes(pluginCleaned)
  tempautoadd = nil

  if hs.eventtap.checkKeyboardModifiers().cmd then
    if _G.autoadd == 1 then
      tempautoadd = 0
    elseif _G.autoadd == 0 then
      tempautoadd = 1
    end
  else
    tempautoadd = _G.autoadd
  end

  print("tempautoadd = " .. tempautoadd .. " and _G.autoadd = " .. _G.autoadd)

  if tempautoadd == 1 then
    local sleep = hs.osascript.applescript([[delay ]] .. _G.loadspeed)
    if sleep == true then
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "return", 0)
    else
      hs.alert.show("applescript sleep failed to execute properly")
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "return", 0)
    end
    hs.eventtap.keyStroke({}, "escape", 0)
  end

  
  if _G.resettobrowserbookmark == 1 then
    if _G.loadspeed <= 0.5 then
      sleep2 = hs.osascript.applescript([[delay 0.1]])
    else
      sleep2 = hs.osascript.applescript([[delay 0.3]])
    end
    
    if sleep2 ~= nil then
    	bookmarkfunc()
    end
  end
  return

end

-- piano macro stuff below here

buttonstatevar = false
local keyHandler = function(e)
    local buttonstate = e:getButtonState(0)
    local buttonstate2 = e:getButtonState(1)
    local clickState = hs.eventtap.event.properties.mouseEventClickState
    if buttonstate == true and _G.buttonstatevar == false then
        _G.buttonstatevar = true
        local point = {}
        point = hs.mouse.getAbsolutePosition()
        point["__luaSkinType"] = nil
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):post()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):post()
        hs.timer.usleep(6000)
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 2):post()
        -- print("clicc")
    elseif buttonstate == false and _G.buttonstatevar == true then
        _G.buttonstatevar = false
        local point = {}
        point = hs.mouse.getAbsolutePosition()
        point["__luaSkinType"] = nil
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 2):post()
        -- print("unclicc")
        if _G.pressingshit == true then
          _G.shitvar = 1
        end
        if _G.shitvar == 1 and _G.pressingshit == false then
          _G.shitvar = 0
          stampselect = nil
          return
        end
        if _G.stampselect ~= nil then
          _G[stampselect]()
          if pressingshit == false then
            stampselect = nil
            _G.shitvar = 0
          end
        end
    end
    if buttonstate2 == true and not hs.eventtap.checkKeyboardModifiers().shift == true then -- macro for showing automation
      -- print("right clicc")
      if firstRightClick then
        firstRightClick:stop()
      end
      if firstDown ~= nil or secondDown ~= nil then
        timeRMBTime, firstDown, secondDown = 0, false, true
      end
      firstRightClick:start()
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "return", 0)
    elseif buttonstate2 == true and hs.eventtap.checkKeyboardModifiers().shift == true then -- macro for showing automation in a new lane
      -- print("right clicc with shift")
      -- local sleep = hs.osascript.applescript([[delay 0.01]])
      if firstRightClick then
        firstRightClick:stop()
      end
      if firstDown ~= nil or secondDown ~= nil then
        timeRMBTime, firstDown, secondDown = 0, false, true
      end
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "down", 0)
      hs.eventtap.keyStroke({}, "return", 0)
      firstRightClick:start()
    end
end

-- this is the hammerspoon equivalent of autohotkey's "getKeyState"
keyhandlervar = false
_G.pressingshit = false
local modifierHandler = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp, hs.eventtap.event.types.flagsChanged }, function(e)

    local keycode = e:getKeyCode()
    local eventtype = e:getType()
    if keycode == _G.pianorollmacro and eventtype == 10 and _G.keyhandlervar == false then -- if the keyhandler is on, the event function above will start
        print("keyhandler on")
        _G.keyhandlervar = true
        keyhandlerevent = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.leftMouseUp, hs.eventtap.event.types.rightMouseDown }, keyHandler):start()
    elseif keycode == _G.pianorollmacro and eventtype == 11 and _G.keyhandlervar == true then -- module.keyListener then
        print("keyhandler off")
        _G.keyhandlervar = false
        keyhandlerevent:stop()
        keyhandlerevent = nil
    end

    local flags = e:getFlags()
    local onlyShiftPressed = false
    for k, v in pairs(flags) do
        onlyShiftPressed = v and k == "shift"
        if not onlyShiftPressed then break end
    end
    
    if onlyShiftPressed and _G.pressingshit == false then
        _G.pressingshit = true
        -- print("shit on")
    -- however, adding additional modifiers afterwards is ok... its only when we have no flags that we switch back off
    elseif not next(flags) and _G.pressingshit == true then
        -- print("shit off")
        _G.pressingshit = false
    end

    return false
end):start()

function cheatmenu()
  local b, t, o = hs.osascript.applescript[[display dialog "Enter cheat:" default answer "" buttons {"Ok", "Cancel"} default button "Ok" cancel button "Cancel" with title "A mysterious aura surrounds you..." with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog.icns"]]
  if o == nil then
    return false
  end
  enteredcheat = o:gsub([[.*(.*)%(%"]],"%1")
  enteredcheat = enteredcheat:gsub([[(.*)%".*]],"%1")
  button = o:gsub([[%"%)%,.*(.*)]],"")
    -- gives [[{ 'bhit':'utxt'("Ok]] because I'm sloppy
  print(button)
  print(enteredcheat)
  enteredcheat = enteredcheat:lower()
  if button == [[{ 'bhit':'utxt'("Cancel]] then
    return false
  elseif button == [[{ 'bhit':'utxt'("Ok]] then
    if enteredcheat == "" then
      return false
    elseif enteredcheat == "gaster"then
      os.exit()
    elseif enteredcheat == "collab bro" or enteredcheat == "als" or enteredcheat == "adg" then
      b, t, o = hs.osascript.applescript([[tell application "Live" to display dialog "Doing this will exit your current project without saving. Are you sure?" buttons {"Yes", "No"} default button "No" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
      b = nil
      t = nil
      if o == [[{ 'bhit':'utxt'("Yes") }]] then
        hs.application.find("Live"):kill()
        hs.eventtap.keyStroke({"shift"}, "D", 0)
        while true do
          if hs.application.find("Live") == nil then
            break
          else
            hs.osascript.applescript([[delay 1]])
          end
        end
        print("live is closed")
        os.execute([[mkdir -p ~/.hammerspoon/resources/als\ Lessons]])
        os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/als\ Lessons/lessonsEN.txt ~/.hammerspoon/resources/als\ Lessons]])
        os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/als.als ~/.hammerspoon/resources]])
        print("done cloning project")
        hs.osascript.applescript([[delay 2
          tell application "Finder" to open POSIX file "]] .. homepath .. [[/.hammerspoon/resources/als.als"]])
        return true
      end

    elseif enteredcheat == "303" or enteredcheat == "sylenth" then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/arp303.mp3 ~/.hammerspoon/resources/]])
      local soundobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/arp303.mp3")
      soundobj:device(nil)
      soundobj:loopSound(false)
      soundobj:play()
      os.execute("rm ~/.hammerspoon/resources/arp303.mp3")
      hs.osascript.applescript([[delay ]].. math.ceil(soundobj:duration()))
      msgBox("thank you for trying this demo")

    elseif enteredcheat == "image line" or enteredcheat == "fl studio" then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/flstudio.mp3 ~/.hammerspoon/resources/]])
      local soundobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/flstudio.mp3")
      soundobj:device(nil)
      soundobj:loopSound(false)
      soundobj:play()
      os.execute("rm ~/.hammerspoon/resources/flstudio.mp3")

    elseif enteredcheat == "ghost" or enteredcheat == "ilwag" or enteredcheat == "lvghst" then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/lvghst.mp3 ~/.hammerspoon/resources/]])
      local soundobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/lvghst.mp3")
      soundobj:device(nil)
      soundobj:loopSound(false)
      soundobj:play()
      os.execute("rm ~/.hammerspoon/resources/lvghst.mp3")

    elseif enteredcheat == "live enhancement sweet" or enteredcheat == "les" or enteredcheat == "sweet" then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/LES_vox.wav ~/.hammerspoon/resources/]])
      local soundobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/LES_vox.wav")
      soundobj:device(nil)
      soundobj:loopSound(false)
      soundobj:play()
      os.execute("rm ~/.hammerspoon/resources/LES_vox.wav")

    elseif enteredcheat == "yo twitter" or enteredcheat == "twitter" then
      os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/yotwitter.mp3 ~/.hammerspoon/resources/]])
      local soundobj = hs.sound.getByFile(homepath .. "/.hammerspoon/resources/yotwitter.mp3")
      soundobj:device(nil)
      soundobj:loopSound(false)
      soundobj:play()
      os.execute("rm ~/.hammerspoon/resources/ yotwitter.mp3")
      hs.osascript.applescript([[open location "https://twitter.com/aevitunes"
      open location "https://twitter.com/sylvianyeah"
      open location "https://twitter.com/DylanTallchief"
      open location "https://twitter.com/nyteout"
      open location "https://twitter.com/InvertedSilence"
      open location "https://twitter.com/FalseProdigyUS"
      open location "https://twitter.com/DirectOfficial"]])
      os.execute("rm ~/.hammerspoon/resources/yotwitter.mp3")

    elseif enteredcheat == "owo" or enteredcheat == "uwu" or enteredcheat == "what's this" or enteredcheat == "what" then
      msgboxscript = [[display dialog "owowowowoowoowowowoo what's this????????? ^^ nya?" buttons {"ok"} default button "ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]]

    elseif enteredcheat == "subscribe to dylan tallchief" or enteredcheat == "#dylongang" or enteredcheat == "dylan tallchief" or enteredcheat == "dylantallchief" then
      hs.osascript.applescript([[open location "https://www.youtube.com/c/DylanTallchief?sub_confirmation=1"]])
    end

    soundobj = nil
  end
end

-- application watcher -- 

function disablemacros()
  threadsenabled = false
  -- hs.alert.show("eventtap threads disabled")
  if dingodango then
    dingodango:stop()
  end
  directshyper:disable()
  _G.quickmacro:stop()
  firstRightClick:stop()

  if keyhandlerevent then keyhandlerevent:stop() end
  modifierHandler:stop()
end

function enablemacros()
  -- hs.alert.show("eventtap threads enabled")
  threadsenabled = true
  if _G.enabledebug == 1 then
    dingodango:start()
  end
  directshyper:enable()
  _G.quickmacro:start()
  firstRightClick:start()
  modifierHandler:start()
end

disablemacros() -- macros are off by default because live is never focused at this point in time
-- if it was, the watcher would turn it on again anyway

function setstricttime()
  -- hs.alert.show("you pressed it")

    local appname = hs.application.find("Live") -- getting new track title

  if _G.stricttimevar == true then
    menubarwithdebugoff[7].state = "off"
    menubartabledebugon[10].state = "off"
    _G.stricttimevar = false
    if appname then
      clock:start()
    end
  else
    menubarwithdebugoff[7].state = "on"
    menubartabledebugon[10].state = "on"
    _G.stricttimevar = true
    if testLive() ~= true then
      clock:stop()
    end
  end
  buildMenuBar()
end

function coolfunc(hswindow, appname, straw) -- function that handles saving and loading of project itmes

  if trackname ~= nil then -- saving old time
    oldtrackname = trackname
    print(_G["timer_" .. oldtrackname])
    os.execute([[mkdir ~/.hammerspoon/resources/time]])
    local filepath = homepath .. [[/.hammerspoon/resources/time/]] .. oldtrackname .. "_time" .. [[.txt]]
    local f2=io.open(filepath,"r")
    if f2~=nil then
      io.close(f2)
      os.execute([[rm ~/.hammerspoon/resources/time/]] .. oldtrackname .. "_time" .. [[.txt]])
    end
    os.execute([[echo ']] .. _G["timer_" .. oldtrackname] .. [[' >~/.hammerspoon/resources/time/]] .. oldtrackname .. "_time" .. [[.txt]])
    _G["timer_" .. oldtrackname] = nil
  end

  local appname = hs.application.find("Live") -- getting new track title
  if appname then
    local mainwindowname = appname:mainWindow():title()
    if string.find(mainwindowname, "%[") ~= nil and string.find(mainwindowname, "%]") ~= nil then
      trackname = (mainwindowname:gsub(".*(.*)%[", ""))
      trackname = (trackname:gsub("%].*(.*)", ""))
      trackname = trackname:gsub("[%p%c%s]", "_")
      print("trackname = " .. trackname)
    else
      trackname = "unsaved_project"
    end
  else
    trackname = nil
    return
  end

  filepath = homepath .. [[/.hammerspoon/resources/time/]] .. trackname .. "_time" .. [[.txt]] -- loading old time (if it exists)
  local f=io.open(filepath,"r")
  if f~=nil then 
    print("timer file found")
    local lines = {}
    for line in f:lines() do
      print("old timer found for this project: " .. line)
      _G["timer_" .. trackname] = line
    end
    return true 
  else
    return
  end
end
windowfilter = hs.window.filter.new({'Live'}, nil) -- activating the window filter
windowfilter:subscribe(hs.window.filter.windowTitleChanged,coolfunc)

function timerfunc() -- function that writes the time (currently in seconds)
  if trackname == nil then
    coolfunc()
  end
  if trackname ~= nil then
    if _G["timer_" .. trackname] == nil then
      _G["timer_" .. trackname] = 1
    else 
      _G["timer_" .. trackname] = _G["timer_" .. trackname] + 1
    end
  end
end
clock = hs.timer.new(1, timerfunc)

function requesttime()
  local currenttime = nil

  if trackname == nil then
  hs.osascript.applescript([[tell application "System Events" to display dialog "There was no open project detected. Please open or focus Live and try again." buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite"]])
  return
  end

  if _G["timer_" .. trackname] <= 0 or _G["timer_" .. trackname] == nil then
    currenttime = "0 hours, 0 minutes, and 0 seconds"
  else
    hours = string.format("%02.f", math.floor(_G["timer_" .. trackname]/3600));
    mins = string.format("%02.f", math.floor(_G["timer_" .. trackname]/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(_G["timer_" .. trackname] - hours*3600 - mins *60));
    if hours == "00" or hours == nil then hours = "0" else hours = hours:match("0*(%d+)") end
    if mins == "00" or mins == nil then mins = "0" else mins = mins:match("0*(%d+)") end
    currenttime = hours .. " hours, " .. mins .. " minutes, and " .. secs .. " seconds"
  end

  if trackname == "unsaved_project" then
    b, t, o = hs.osascript.applescript([[tell application "Live Enhancement Suite" to display dialog "The total time you've spent in unsaved projects is" & return & "]] .. currenttime .. [[." buttons {"Reset Time", "Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  else
    b, t, o = hs.osascript.applescript([[tell application "Live Enhancement Suite" to display dialog "The total time you've spent in the []] .. trackname .. [[] project is" & return & "]] .. currenttime .. [[." buttons {"Reset Time", "Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  end
  b = nil
  t = nil
  if o == [[{ 'bhit':'utxt'("Reset Time") }]] then
    b, t, o = hs.osascript.applescript([[tell application "Live Enhancement Suite" to display dialog "Are you sure?" buttons {"Yes", "No"} default button "No" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
    if o == [[{ 'bhit':'utxt'("Yes") }]] then
      _G["timer_" .. trackname] = nil
      _G["timer_" .. oldtrackname] = nil
      os.execute([[rm ~/.hammerspoon/resources/time/]] .. trackname .. "_time" .. [[.txt]])
      coolfunc()
    end
  end
  hs.application.launchOrFocus("Live")
end


threadsenabled = false
appwatcher = hs.application.watcher.new(function(name,event,app) appwatch(name,event,app) end):start() -- terminates hotkeys when ableton is unfocussed
local i = 1
function appwatch(name, event, app)
  if hs.window.focusedWindow() == nil then
    goto epicend
    return
  end

  if event == hs.application.watcher.activated or hs.application.watcher.deactivated then
    if hs.window.focusedWindow() then
      if hs.window.focusedWindow():application():title() == "Live" then
        if threadsenabled == false then
          print("live is in window focus")
          enablemacros()
          clock:start()
        end
      elseif threadsenabled == true then
        print("live is not in window focus")
        disablemacros()
        if _G.stricttimevar == true then
          clock:stop()
        else
          print("clock wasn't stopped because strict time is off")
        end
      end
    end
  end
  ::epicend::

  if event == hs.application.watcher.terminated then
    if clock:running() == true then
      clock:stop()
    end
    coolfunc()
    print("Live was quit")
  end
end

-- SCALES START HERE --

function Major()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Minor()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function MinorH()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function MinorM()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Dorian()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Phrygian()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Lydian()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Mixolydian()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Locrean()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Blues()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function BluesMaj()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Arabic()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Gypsy()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Diminished()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Dominantbebop()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Wholetone()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

-- push scales start

function Superlocrian()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Bhairav()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end


function HungarianM()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function GypsyM()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Hirajoshi()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) 
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Insen()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) 
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Iwato()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Kumoi()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Pelog()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Spanish()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end
-- push scales end

function Chromatic()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function MajorPentatonic()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function MinorPentatonic()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

-- CHORDS START HERE --

function Octaves()
    hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
    for i = 1, 12, 1 do
      hs.eventtap.keyStroke({}, "Up", 0)
    end
end

function Powerchord()
    hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
    for i = 1, 7, 1 do
      hs.eventtap.keyStroke({}, "Up", 0)
    end
end

function Maj()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end 

function Min()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end 

function Aug()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end 

function Dim()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end 

function Maj7()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end

function Min7()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end

function Dom7()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end

function Maj9()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end

function Min9()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 3, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0)
  for i = 1, 4, 1 do
    hs.eventtap.keyStroke({}, "Up", 0)
  end
end

function Fold3()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Fold7()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end

function Fold9()
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
  hs.eventtap.keyStroke({"cmd"}, "C", 0) ; hs.eventtap.keyStroke({"cmd"}, "V", 0) ; hs.eventtap.keyStroke({}, "Up", 0) ; hs.eventtap.keyStroke({}, "Up", 0)
end


if _G.bookmarkx == nil or _G.dynamicreload == nil or _G.double0todelete == nil then
  b, t, o = hs.osascript.applescript([[tell application "System Events" to display dialog "Your settings.ini file is missing parameters because it is old. Do you want to replace it with the new default? This will clear your personal settings (not the configuration of the menu)" buttons {"Yes", "No"} default button "Yes" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  print(o)
  b = nil
  t = nil
  if o == [[{ 'bhit':'utxt'("Yes") }]] then
    os.execute([[rm ~/.hammerspoon/settings.ini]])
    os.execute([[cp /Applications/Live\ Enhancement\ Suite.app/Contents/.Hidden/settings.ini ~/.hammerspoon/]])
    reloadLES()
  elseif o == [[{ 'bhit':'utxt'("No") }]] then
    hs.osascript.applescript([[tell application "System Events" to display dialog "LES will exit." buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
    os.exit()
  end
  o = nil
end
hs.dockIcon(false)
if console then console:close() end