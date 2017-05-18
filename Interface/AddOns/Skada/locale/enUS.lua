local L = LibStub("AceLocale-3.0"):NewLocale("Skada", "enUS", true)

L["Include set"] = true
L["Include set name in title bar"] = true
L["Disable"] = true
L["Profiles"] = true
L["Hint: Left-Click to toggle Skada window."] = true
L["Shift + Left-Click to reset."] = true
L["Right-click to open menu"] = true
L["Options"] = true
L["Appearance"] = true
L["A damage meter."] = true
L["Skada summary"] = true

L["opens the configuration window"] = true
L["Memory usage is high. You may want to reset Skada, and enable one of the automatic reset options."] = true
L["resets all data"] = true

L["Current"] = "Current fight"
L["Total"] = "Total"

L["All data has been reset."] = true
L["Skada: Modes"] = true
L["Skada: Fights"] = true

-- Options
L["Disabled Modules"] = true
L["This change requires a UI reload. Are you sure?"] = true
L["Tick the modules you want to disable."] = true
L["Bar font"] = true
L["The font used by all bars."] = true
L["Bar font size"] = true
L["The font size of all bars."] = true
L["Bar texture"] = true
L["The texture used by all bars."] = true
L["Bar spacing"] = true
L["Distance between bars."] = true
L["Bar height"] = true
L["The height of the bars."] = true
L["Bar width"] = true
L["The width of the bars."] = true
L["Bar color"] = true
L["Choose the default color of the bars."] = true
L["Max bars"] = true
L["The maximum number of bars shown."] = true
L["Bar orientation"] = true
L["The direction the bars are drawn in."] = true
L["Left to right"] = true
L["Right to left"] = true
L["Combat mode"] = true
L["Automatically switch to set 'Current' and this mode when entering combat."] = true
L["None"] = true
L["Return after combat"] = true
L["Return to the previous set and mode after combat ends."] = true
L["Show minimap button"] = true
L["Toggles showing the minimap button."] = true

L["reports the active mode"] = true
L["Skada: %s for %s:"] = "Skada: %s for %s:"
L["Only keep boss fighs"] = "Only keep boss fights"
L["Boss fights will be kept with this on, and non-boss fights are discarded."] = true
L["Show raw threat"] = true
L["Shows raw threat percentage relative to tank instead of modified for range."] = true

L["Lock window"] = "Lock window"
L["Locks the bar window in place."] = "Locks the bar window in place."
L["Reverse bar growth"] = "Reverse bar growth"
L["Bars will grow up instead of down."] = "Bars will grow up instead of down."
L["Number format"] = "Number format"
L["Controls the way large numbers are displayed."] = "Controls the way large numbers are displayed."
L["Number set duplicates"] = "Number set duplicates"
L["Append a count to set names with duplicate mob names."] = "Append a count to set names with duplicate mob names."
L["Set format"] = "Set format"
L["Controls the way set names are displayed."] = "Controls the way set names are displayed."
L["Reset on entering instance"] = "Reset on entering instance"
L["Controls if data is reset when you enter an instance."] = "Controls if data is reset when you enter an instance."
L["Reset on joining a group"] = "Reset on joining a group"
L["Controls if data is reset when you join a group."] = "Controls if data is reset when you join a group."
L["Reset on leaving a group"] = "Reset on leaving a group"
L["Controls if data is reset when you leave a group."] = "Controls if data is reset when you leave a group."
L["General options"] = "General options"
L["Mode switching"] = "Mode switching"
L["Data resets"] = "Data resets"
L["Bars"] = "Bars"

L["Yes"] = "Yes"
L["No"] = "No"
L["Ask"] = "Ask"
L["Condensed"] = "Condensed"
L["Detailed"] = "Detailed"

L["'s Death"] = "'s Death"
L["Hide when solo"] = "Hide when solo"
L["Hides Skada's window when not in a party or raid."] = "Hides Skada's window when not in a party or raid."

L["Title bar"] = "Title bar"
L["Background texture"] = "Background texture"
L["The texture used as the background of the title."] = "The texture used as the background of the title."
L["Border texture"] = "Border texture"
L["The texture used for the border of the title."] = "The texture used for the border of the title."
L["Border thickness"] = "Border thickness"
L["The thickness of the borders."] = "The thickness of the borders."
L["Background color"] = "Background color"
L["The background color of the title."] = "The background color of the title."

L["'s "] = "'s "
L["Do you want to reset Skada?"] = "Do you want to reset Skada?"
L["'s Fails"] = "'s Fails"
L["The margin between the outer edge and the background texture."] = "The margin between the outer edge and the background texture."
L["Margin"] = "Margin"
L["Window height"] = "Window height"
L["The height of the window. If this is 0 the height is dynamically changed according to how many bars exist."] = "The height of the window. If this is 0 the height is dynamically changed according to how many bars exist."
L["Adds a background frame under the bars. The height of the background frame determines how many bars are shown. This will override the max number of bars setting."] = "Adds a background frame under the bars. The height of the background frame determines how many bars are shown. This will override the max number of bars setting."
L["Enable"] = "Enable"
L["Background"] = "Background"
L["The texture used as the background."] = "The texture used as the background."
L["The texture used for the borders."] = "The texture used for the borders."
L["The color of the background."] = "The color of the background."
L["Data feed"] = "Data feed"
L["Choose which data feed to show in the DataBroker view. This requires an LDB display addon, such as Titan Panel."] = "Choose which data feed to show in the DataBroker view. This requires an LDB display addon, such as Titan Panel."
L["RDPS"] = "RDPS"
L["Damage: Personal DPS"] = "Damage: Personal DPS"
L["Damage: Raid DPS"] = "Damage: Raid DPS"
L["Threat: Personal Threat"] = "Threat: Personal Threat"

L["Data segments to keep"] = "Data segments to keep"
L["The number of fight segments to keep. Persistent segments are not included in this."] = "The number of fight segments to keep. Persistent segments are not included in this."

L["Alternate color"] = "Alternate color"
L["Choose the alternate color of the bars."] = "Choose the alternate color of the bars."

L["Threat warning"] = "Threat warning"
L["Flash screen"] = "Flash screen"
L["This will cause the screen to flash as a threat warning."] = "This will cause the screen to flash as a threat warning."
L["Shake screen"] = "Shake screen"
L["This will cause the screen to shake as a threat warning."] = "This will cause the screen to shake as a threat warning."
L["Play sound"] = "Play sound"
L["This will play a sound as a threat warning."] = "This will play a sound as a threat warning."
L["Threat sound"] = "Threat sound"
L["The sound that will be played when your threat percentage reaches a certain point."] = "The sound that will be played when your threat percentage reaches a certain point."
L["Threat threshold"] = "Threat threshold"
L["When your threat reaches this level, relative to tank, warnings are shown."] = "When your threat reaches this level, relative to tank, warnings are shown."

L["Enables the title bar."] = "Enables the title bar."

L["Total healing"] = "Total healing"
L["Interrupts"] = "Interrupts"

L["Skada Menu"] = "Skada Menu"
L["Switch to mode"] = "Switch to mode"
L["Report"] = "Report"
L["Toggle window"] = "Toggle window"
L["Configure"] = "Configure"
L["Delete segment"] = "Delete segment"
L["Keep segment"] = "Keep segment"
L["Mode"] = "Mode"
L["Lines"] = "Lines"
L["Channel"] = "Channel"
L["Send report"] = "Send report"
L["No mode selected for report."] = "No mode selected for report."
L["Say"] = "Say"
L["Raid"] = "Raid"
L["Party"] = "Party"
L["Guild"] = "Guild"
L["Officer"] = "Officer"
L["Self"] = "Self"

L["'s Healing"] = "'s Healing"

L["Enemy damage done"] = "Enemy damage done"
L["Enemy damage taken"] = "Enemy damage taken"
L["Damage on"] = "Damage on"
L["Damage from"] = "Damage from"

L["Delete window"] = "Delete window"
L["Deletes the chosen window."] = "Deletes the chosen window."
L["Choose the window to be deleted."] = "Choose the window to be deleted."
L["Enter the name for the new window."] = "Enter the name for the new window."
L["Create window"] = "Create window"
L["Windows"] = "Windows"

L["Switch to segment"] = "Switch to segment"
L["Segment"] = "Segment"

L["Whisper"] = "Whisper"
L["No mode or segment selected for report."] = "No mode or segment selected for report."
L["Name of recipient"] = "Name of recipient"

L["Resist"] = "Resist"
L["Reflect"] = "Reflect"
L["Parry"] = "Parry"
L["Immune"] = "Immune"
L["Evade"] = "Evade"
L["Dodge"] = "Dodge"
L["Deflect"] = "Deflect"
L["Block"] = "Block"
L["Absorb"] = "Absorb"

L["Last fight"] = "Last fight"
L["Disable while hidden"] = "Disable while hidden"
L["Skada will not collect any data when automatically hidden."] = "Skada will not collect any data when automatically hidden."
L["Data Collection"] = "Data Collection"
L["ENABLED"] = "ENABLED"
L["DISABLED"] = "DISABLED"

L["Rename window"] = "Rename window"
L["Enter the name for the window."] = "Enter the name for the window."

L["Bar display"] = "Bar display"
L["Display system"] = "Display system"
L["Choose the system to be used for displaying data in this window."] = "Choose the system to be used for displaying data in this window."

L["Hides HPS from the Healing modes."] = "Hides HPS from the Healing modes."
L["Do not show HPS"] = "Do not show HPS"

L["Do not show DPS"] = "Do not show DPS"
L["Hides DPS from the Damage mode."] = "Hides DPS from the Damage mode."

L["Class color bars"] = "Class color bars"
L["When possible, bars will be colored according to player class."] = "When possible, bars will be colored according to player class."
L["Class color text"] = "Class color text"
L["When possible, bar text will be colored according to player class."] = "When possible, bar text will be colored according to player class."

L["Reset"] = "Reset"
L["Show tooltips"] = "Show tooltips"
L["Mana gained"] = "Mana gained"
L["Shows tooltips with extra information in some modes."] = "Shows tooltips with extra information in some modes."

L["Average hit:"] = "Average hit:"
L["Maximum hit:"] = "Maximum hit:"
L["Minimum hit:"] = "Minimum hit:"
L["Absorbs"] = "Absorbs"
L["'s Absorbs"] = "'s Absorbs"

L["Do not show TPS"] = "Do not show TPS"
L["Do not warn while tanking"] = "Do not warn while tanking"

L["Hide in PvP"] = "Hide in PvP"
L["Hides Skada's window when in Battlegrounds/Arenas."] = "Hides Skada's window when in Battlegrounds/Arenas."

L["Healed players"] = "Healed players"
L["Healed by"] = "Healed by"
L["Absorb details"] = "Absorb details"
L["Spell details"] = "Spell details"
L["Healing spell list"] = "Healing spell list"
L["Damage spell list"] = "Damage spell list"
L["Death log"] = "Death log"
L["Damage done per player"] = "Damage done per player"
L["Damage taken per player"] = "Damage taken per player"
L["Damage spell details"] = "Damage spell details"
L["Healing spell details"] = "Healing spell details"
L["Mana gain spell list"] = "Mana gain spell list"
L["List of damaging spells"] = "List of damaging spells"
L["Debuff spell list"] = "Debuff spell list"

L["Click for"] = "Click for"
L["Shift-Click for"] = "Shift-Click for"
L["Control-Click for"] = "Control-Click for"
L["Default"] = "Default"
L["Top right"] = "Top right"
L["Top left"] = "Top left"
L["Position of the tooltips."] = "Position of the tooltips."
L["Tooltip position"] = "Tooltip position"

L["Damaged mobs"] = "Damaged mobs"
L["Shows a button for opening the menu in the window title bar."] = "Shows a button for opening the menu in the window title bar."
L["Show menu button"] = "Show menu button"

L["Debuff uptimes"] = true
L["'s Debuffs"] = true
L["Deaths"] = true
L["Damage taken"] = true
L["Attack"] = true
L["'s Damage taken"] = true
L["DPS"] = true
L["Damage"] = true
L["'s Damage"] = true
L["Hit"] = true
L["Critical"] = true
L["Missed"] = true
L["Resisted"] = true
L["Blocked"] = true
L["Glancing"] = true
L["Crushing"] = "Crushing"
L["Multistrike"] = STAT_MULTISTRIKE or true -- XXX compat
L["Absorbed"] = true
L["Dispels"] = true
L["Fails"] = true
L["'s Fails"] = true
L["HPS"] = "HPS"
L["Healing"] = true
L["'s Healing"] = true
L["Overhealing"] = true
L["Threat"] = true
L["Power"] = true
L["Enemies"] = true
L["Debuffs"] = true
L["DamageTaken"] = "Damage Taken"
L["TotalHealing"] = "Total Healing"

L["Announce CC breaking to party"] = true
L["Ignore Main Tanks"] = true
L["%s on %s removed by %s's %s"]= true
L["%s on %s removed by %s"]= true
L["CC"] = true
L["CC breakers"] = true
L["CC breaks"] = true
L["Start new segment"] = true

L["Columns"] = "Columns"
L["Overheal"] = "Overheal"
L["Percent"] = "Percent"
L["TPS"] = "TPS"

L["%s dies"] = "%s dies"
L["Timestamp"] = "Timestamp"
L["Change"] = "Change"
L["Health"] = "Health"

L["Hide in combat"] = "Hide in combat"
L["Hides Skada's window when in combat."] = "Hides Skada's window when in combat."

L["Tooltips"] = "Tooltips"
L["Informative tooltips"] = "Informative tooltips"
L["Shows subview summaries in the tooltips."] = "Shows subview summaries in the tooltips."
L["Subview rows"] = "Subview rows"
L["The number of rows from each subview to show when using informative tooltips."] = "The number of rows from each subview to show when using informative tooltips."

L["Damage done"] = "Damage done"
L["Active time"] = "Active time"
L["Segment time"] = "Segment time"
L["Absorbs and healing"] = "Absorbs and healing"
L["Activity"] = true

L["Show rank numbers"] = "Show rank numbers"
L["Shows numbers for relative ranks for modes where it is applicable."] = "Shows numbers for relative ranks for modes where it is applicable."

L["Use focus target"] = "Use focus target"
L["Shows threat on focus target, or focus target's target, when available."] = "Shows threat on focus target, or focus target's target, when available."

L["Show spark effect"] = "Show spark effect"

L["List of damaged players"] = "List of damaged players"
L["Damage taken by spell"] = "Damage taken by spell"
L["targets"] = "targets"

L["Aggressive combat detection"] = "Aggressive combat detection"
L["Skada usually uses a very conservative (simple) combat detection scheme that works best in raids. With this option Skada attempts to emulate other damage meters. Useful for running dungeons. Meaningless on boss encounters."] = "Skada usually uses a very conservative (simple) combat detection scheme that works best in raids. With this option Skada attempts to emulate other damage meters. Useful for running dungeons. Meaningless on boss encounters."

L["Clickthrough"] = "Clickthrough"
L["Disables mouse clicks on bars."] = "Disables mouse clicks on bars."
L["DTPS"] = "DTPS"
L["Healing taken"] = "Healing taken"

L["Wipe mode"] = "Wipe mode"
L["Automatically switch to set 'Current' and this mode after a wipe."] = "Automatically switch to set 'Current' and this mode after a wipe."

L["Merge pets"] = "Merge pets"
L["Merges pets with their owners. Changing this only affects new data."] = "Merges pets with their owners. Changing this only affects new data."

L["Show totals"] = "Show totals"
L["Shows a extra row with a summary in certain modes."] = "Shows a extra row with a summary in certain modes."

L["There is nothing to report."] = "There is nothing to report."

L["Buttons"] = "Buttons"
L["Buff uptimes"] = "Buff uptimes"
L["Buff spell list"] = "Buff spell list"
L["'s Buffs"] = "'s Buffs"

L["Deletes the chosen window."] = "Deletes the chosen window."
L["Delete window"] = "Delete window"
L["Window"] = "Window"
L["Scale"] = "Scale"
L["Sets the scale of the window."] = "Sets the scale of the window."

L["Snaps the window size to best fit when resizing."] = "Snaps the window size to best fit when resizing."
L["Snap to best fit"] = "Snap to best fit"

L["Hide window"] = "Hide window"
L["Absorb spells"] = "Absorb spells"

L["Choose the background color of the bars."] = "Choose the background color of the bars."

L["Font flags"] = "Font flags"
L["Sets the font flags."] = "Sets the font flags."
L["None"] = "None"
L["Outline"] = "Outline"
L["Thick outline"] = "Thick outline"
L["Monochrome"] = "Monochrome"
L["Outlined monochrome"] = "Outlined monochrome"

L["The height of the title frame."] = "The height of the title frame."
L["Title height"] = "Title height"
L["Use class icons where applicable."] = "Use class icons where applicable."
L["Class icons"] = "Class icons"

L["RealID"] = "RealID"
L["Instance"] = "Instance"

L["Enemy healing done"] = "Enemy healing done"
L["Enemy healing taken"] = "Enemy healing taken"

L["Stop"] = "Stop/Resume"
L["Autostop"] = "Stop early on wipe"
L["Autostop description"] = "Automatically stops the current segment after a certain amount of raid members have died."

L["Stop description"] = "Stops or resumes the current segment. Useful for discounting data after a wipe. Can also be set to automatically stop in the settings."
L["Segment description"] = "Jump to a specific segment."
L["Mode description"] = "Jump to a specific mode."
L["Reset description"] = "Resets all fight data except those marked as kept."
L["Report description"] = "Opens a dialog that lets you report your data to others in various ways."
L["Configure description"] = "Lets you configure the active Skada window."

L["Role icons"] = true
L["Use role icons where applicable."] = true

L["Overhealing spells"] = true

L["Whisper Target"] = true

L["Always show self"] = true
L["Keeps the player shown last even if there is not enough space."] = true

L["Strata"] = true
L["This determines what other frames will be in front of the frame."] = true

L["Fixed bar width"] = true
L["If checked, bar width is fixed. Otherwise, bar width depends on the text width."] = true

L["Text color"] = true
L["Choose the default color."] = true
L["Hint: Left-Click to set active mode."] = true
L["Right-click to set active set."] = true
L["Shift + Left-Click to open menu."] = true
L["Title color"] = true
L["The text color of the title."] = true
L["Border color"] = true
L["The color used for the border."] = true

L["Tweaks"] = true
L["Inline bar display"] = true
L["Data text"] = true
L["Width"] = true
L["Height"] = true
L["Tile"] = true
L["Tile the background texture."] = true
L["Tile size"] = true
L["The size of the texture pattern."] = true
L["Border"] = true
L["General"] = true
L["Inline display is a horizontal window style."] = true
L["Data text acts as an LDB data feed. It can be integrated in any LDB display such as Titan Panel or ChocolateBar. It also has an optional internal frame."] = true
L["Bar display is the normal bar window used by most damage meters. It can be extensively styled."] = true

L["Theme applied!"] = true
L["Themes"] = true
L["Theme"] = true
L["Apply theme"] = true
L["Save theme"] = true
L["Name of your new theme."] = true
L["Name"] = true
L["Save"] = true
L["Apply"] = true
L["Delete"] = true
L["Delete theme"] = true
L["Various tweaks to get around deficiences and problems in the game's combat logs. Carries a small performance penalty."] = true
L["Adds a set of standard themes to Skada. Custom themes can also be used."] = true
L["Smart"] = true
L["Memory usage is high. You may want to reset Skada, and enable one of the automatic reset options."] = true

L["Other"] = true

L["Energy gained"] = true
L["Rage gained"] = true
L["Runic power gained"] = true
L["Holy power gained"] = true
L["Energy gain sources"] = true
L["Rage gain sources"] = true
L["Holy power gain sources"] = true
L["Runic power gain sources"] = true
L["Power gains"] = true
L["Focus gained"] = true
L["Fury gained"] = true
L["Pain gained"] = true
L["Soul Shards gained"] = true
L["Focus gain sources"] = true
L["Fury gain sources"] = true
L["Pain gain sources"] = true
L["Soul Shards gain sources"] = true

L["Minimum"] = true
L["Maximum"] = true
L["Average"] = true

L["Spell school colors"] = true
L["Use spell school colors where applicable."] = true

L["Sort modes by usage"] = true
L["The mode list will be sorted to reflect usage instead of alphabetically."] = true

L["Smooth bars"] = true
L["Animate bar changes smoothly rather than immediately."] = true

L["Update frequency"] = true
L["How often windows are updated. Shorter for faster updates. Increases CPU usage."] = true

L["Buffs"] = true
L["Debuffs"] = true
