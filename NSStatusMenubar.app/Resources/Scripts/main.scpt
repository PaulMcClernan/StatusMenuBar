use framework "Foundation"
use framework "AppKit"
use scripting additions
-- load framework
-- property parent : class "NSObject"

property StatusItem : missing value
property selectedMenu : ""
property theDisplay : ""
-- property defaults : class "NSUserDefaults"
property internalMenuItem : class "NSMenuItem"
property externalMenuItem : class "NSMenuItem"
property newMenu : class "NSMenu"
property OpK : class "NSAlternateKeyMask"
property myMIDIFileNSURL : class "NSURL"
property myMIDIPlayer : class "AVMIDIPlayer"

my makeStatusBar()
my makeMenus()

-- set targetApp to "LiveCode Community 9.0.0 (dp 11)"
-- tell application targetApp
-- activate
-- end tell

on quitAll()
	tell application "TestStack" -- insert the name of your standalone
		quit
	end tell
	tell application "LiveCode Community 9.0.0"
		quit
	end tell
	quit
end quitAll

on flashMenuIcon(pRepeatCnt)
	repeat pRepeatCnt times
		StatusItem's setImage:(current application's NSImage's imageNamed:"menuiconinvert.png")
		delay 0.1
		StatusItem's setImage:(current application's NSImage's imageNamed:"menuicon.png")
		delay 0.1
	end repeat
end flashMenuIcon

on getStatusMenuResFolderPath()
	-- set posixPath to (current application's NSBundle's mainBundle's pathForResource:"menulist" ofType:"txt") as string
	set posixPath to (current application's NSBundle's mainBundle's pathForResource:"") as string
	return posixPath
end getStatusMenuResFolderPath

on makeStatusBar()
	set bar to current application's NSStatusBar's systemStatusBar
	set StatusItem to bar's statusItemWithLength:-1.0
	-- set up the initial NSStatusBars title
	StatusItem's setTitle:" "
	-- set up the initial NSMenu of the statusbar
	set newMenu to current application's NSMenu's alloc()'s initWithTitle:"Custom"
	
	newMenu's setDelegate:me -- Required delegation for when the Status bar Menu is clicked the menu will 
	--  use the delegates method (menuNeedsUpdate:(menu)) to run dynamically update.
	
	StatusItem's setMenu:newMenu --call method to add new menu
	
end makeStatusBar

on makeMenus()
	set posixPath to (current application's NSBundle's mainBundle's pathForResource:"menulist" ofType:"txt") as string
	-- display notification posixPath
	set tMenuTxt to the paragraphs of (read (posixPath as POSIX file)) -- as text -- as «class utf8»
	-- display notification tMenuTxt 
	set someListInstances to tMenuTxt -- set someListInstances to {"One", "Two", "Three", "Four", "Five", "Quit"}
	newMenu's removeAllItems() -- remove existing menu items
	repeat with i from 1 to number of items in someListInstances
		set this_item to item i of someListInstances
		if this_item = "_" then
			set thisMenuItem to current application's NSMenuItem's separatorItem()
			(newMenu's addItem:thisMenuItem)
			(thisMenuItem's setTarget:me) -- required for enabling the menu item
		else
			-- set thisMenuItem's keyEquivalentModifierMask to OpK
			set thisMenuItem to (current application's NSMenuItem's alloc()'s initWithTitle:this_item action:("doSomething" & ":") keyEquivalent:(i as text))
			
			-- 
			set thisMenuItem's keyEquivalentModifierMask to (1048576 + 524288)
			-- 1048576+524288+262144= Command+Option+Control
			-- NSAlternateKeyMask=524288			
			-- NSControlKeyMask=262144
			-- NSCommandKeyMask=1048576
			-- NSShiftKeyMask=131072
			-- NSAlphaShiftKeyMask = 65536 -- Set if Caps Lock key is pressed.
			-- NSNumericPadKeyMask = 2097152 --Set if any key in the numeric keypad is pressed. The numeric keypad is generally on the right side of the keyboard. This is also set if any of the arrow keys are pressed 
			--NSHelpKeyMask = 4194304
			-- NSDeviceIndependentModifierFlagsMask = 16777216 -- Used to retrieve only the device-independent modifier flags, allowing applications to mask off the device-dependent modifier flags, including event coalescing information. Available in Mac OS X v10.4.
			
			set thisMenuItem's tag to i
			(newMenu's addItem:thisMenuItem)
			(thisMenuItem's setTarget:me) -- required for enabling the menu item
		end if
	end repeat
end makeMenus

on removeMenu()
	tell current application's NSStatusBar's systemStatusBar to removeStatusItem:StatusItem
end removeMenu

on doSomething:sender
	set {tag_, title_} to {sender's tag, sender's title}
	set doMenuStr to title_ as string
	set doMenuTagStr to tag_ as string
	display notification "Title: " & doMenuStr & "  Tag: " & doMenuTagStr
	tell application "TestStack" -- insert the name of your standalone
		activate
		«event miscdosc» "dispatch \"doStatusMenu\" to stack \"TestStack\" with " & quote & doMenuStr & quote
	end tell
	tell application "LiveCode Community 9.0.0"
		do script "dispatch \"doStatusMenu\" to stack \"TestStack\" with " & quote & doMenuStr & quote
	end tell
	if doMenuStr = "Quit" then quitAll()
end doSomething:

-- GenericMenuHandlers ---
on launchMyStandAlone()
	tell application "TestStack" --  "LiveCode Community 9.0.0 (dp 11)" -- insert the name of your standalone
		activate
		«event miscdosc» "\"send put \"Hello!\" to stack \"TestStack\""
		-- evaluate("1+2+3")
	end tell
end launchMyStandAlone

on playASound(soundName)
	if soundName is "" then set soundName to "Glass"
	set soundFilePath to "/System/Library/Sounds/" & soundName & ".aiff"
	tell class "NSSound" of current application
		set soundInstance to its (alloc()'s ¬
			initWithContentsOfFile:soundFilePath byReference:true)
	end tell
	soundInstance's setVolume:1.0
	soundInstance's play()
end playASound

StatusItem's setTitle:""
StatusItem's setImage:(current application's NSImage's imageNamed:"menuicon.png")
