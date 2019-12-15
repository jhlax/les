console = hs.appfinder.windowFromWindowTitle("Hammerspoon Console")
if console then console:close() end
hs.dockIcon(true)
currentdir = hs.fs.currentDir()
print(currentdir)
hs.menuIcon(false)
hs.automaticallyCheckForUpdates(false)
hs.uploadCrashData(false)
hs.openConsoleOnDockClick(true)

-- the most important line lmao
bundlePath = hs.processInfo["bundlePath"]

if bundlePath == "/Applications/Live Enhancement Suite.app" then
  print("hammerspoon is in applications dir")
else
  hs.osascript.applescript([[tell application "System Events" to display dialog "Error: LES was not detected in the Applications folder." & return & "Please move the LES app to the Applications folder." buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  os.exit()
end

if hs.accessibilityState() == false then -- testing if hammerspoon has accessibility access.
  hs.osascript.applescript([[tell application "System Events" to display dialog "Accessibility access is disabled which prevents LES from working properly." & return & "Please turn on accessibility access in" & return & "Prefrences > Security & Privacy > Privacy > Accessibility, and try again." buttons {"Ok"} default button "Ok" with title "Live Enhancement Suite" with icon POSIX file "/Applications/Live Enhancement Suite.app/Contents/Resources/LESdialog2.icns"]])
  os.execute("open /System/Library/PreferencePanes/Security.prefPane")
  os.exit()
end

dofile(bundlePath .. [[/Contents/Resources/LESmain.lua]])