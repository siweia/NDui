local L = LibStub("AceLocale-3.0"):GetLocale("Skada", false)
local AceGUI = LibStub("AceGUI-3.0")

-- Mode menu list sorted by category
local function _modeMenu(window, level)
    local info = UIDropDownMenu_CreateInfo()

    local modes = Skada:GetModes()
    local categorized = {}
    for i, module in ipairs(modes) do
        table.insert(categorized, module)
    end
    
    table.sort(categorized, function(a, b)
        local a_score = 0
        local b_score = 0
        if a.category == L['Other'] then
            a_score = 1000
        end
        if b.category == L['Other'] then
            b_score = 1000
        end
        a_score = a_score + (string.byte(a.category, 1) * 10) + string.byte(a:GetName(), 1)
        b_score = b_score + (string.byte(b.category, 1) * 10) + string.byte(b:GetName(), 1)
        return a_score < b_score
    end)
    
    local lastcat = nil
    for i, module in ipairs(categorized) do
        if not lastcat or lastcat ~= module.category then
            if lastcat then
                -- Add a blank separator
                info = UIDropDownMenu_CreateInfo()
                info.disabled = 1
                info.notCheckable = 1
                UIDropDownMenu_AddButton(info, level)
            end

            info = UIDropDownMenu_CreateInfo()
            info.isTitle = 1
            info.text = module.category
            UIDropDownMenu_AddButton(info, level)
            lastcat = module.category
        end

        info = UIDropDownMenu_CreateInfo()
        info.text = module:GetName()
        info.func = function() window:DisplayMode(module) end
        info.checked = (window.selectedmode == module)
        UIDropDownMenu_AddButton(info, level)
    end    
end

local function getDropdownPoint()
	local x,y = GetCursorPosition(UIParent);
	x = x / UIParent:GetEffectiveScale();
	y = y / UIParent:GetEffectiveScale();
	local point
	if x > GetScreenWidth() / 2 then
	  point = "RIGHT"
	else
	  point = "LEFT"
	end
	if y > GetScreenHeight() / 2 then
	  point = "TOP"..point
	else
	  point = "BOTTOM"..point
	end
	return point, x, y
end

-- Configuration menu.
function Skada:OpenMenu(window)
	if not self.skadamenu then
		self.skadamenu = CreateFrame("Frame", "SkadaMenu")
	end
	local skadamenu = self.skadamenu

	skadamenu.displayMode = "MENU"
    local info = UIDropDownMenu_CreateInfo()
	skadamenu.initialize = function(self, level)
	    if not level then return end
        
	    if level == 1 then
	        -- Create the title of the menu
            info = UIDropDownMenu_CreateInfo()
	        info.isTitle = 1
	        info.text = L["Skada Menu"]
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

			for i, win in ipairs(Skada:GetWindows()) do
                info = UIDropDownMenu_CreateInfo()
		        info.text = win.db.name
		        info.hasArrow = 1
		        info.value = win
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)
			end

	        -- Add a blank separator
            info = UIDropDownMenu_CreateInfo()
	        info.disabled = 1
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

			-- Can't report if we are not in a mode.
		if not window or (window and window.selectedmode) then
                info = UIDropDownMenu_CreateInfo()
		        info.text = L["Report"]
				info.func = function() Skada:OpenReportWindow(window) end
		        info.value = "report"
				info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)
		end

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Delete segment"]
	        info.hasArrow = 1
	        info.notCheckable = 1
	        info.value = "delete"
	        UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Keep segment"]
	        info.notCheckable = 1
	        info.hasArrow = 1
	        info.value = "keep"
	        UIDropDownMenu_AddButton(info, level)

	        -- Add a blank separator
            info = UIDropDownMenu_CreateInfo()
	        info.disabled = 1
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Toggle window"]
	        info.func = function() Skada:ToggleWindow() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Reset"]
	        info.func = function() Skada:Reset() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Start new segment"]
	        info.func = function() Skada:NewSegment() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
	        info.text = L["Configure"]
	        info.func = function()
                Skada:OpenOptions(window)
            end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

	        -- Close menu item
            info = UIDropDownMenu_CreateInfo()
	        info.text         = CLOSE
	        info.func         = function() CloseDropDownMenus() end
	        info.checked      = nil
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)
	    elseif level == 2 then
	    	if type(UIDROPDOWNMENU_MENU_VALUE) == "table" then
	    		local window = UIDROPDOWNMENU_MENU_VALUE
	    		-- Display list of modes with current ticked; let user switch mode by checking one.
                info = UIDropDownMenu_CreateInfo()
		        info.isTitle = 1
		        info.text = L["Mode"]
		        UIDropDownMenu_AddButton(info, level)

		        for i, module in ipairs(Skada:GetModes()) do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = module:GetName()
		            info.func = function() window:DisplayMode(module) end
		            info.checked = (window.selectedmode == module)
		            UIDropDownMenu_AddButton(info, level)
		        end

		        -- Separator
                info = UIDropDownMenu_CreateInfo()
		        info.disabled = 1
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)

		        -- Display list of sets with current ticked; let user switch set by checking one.
                info = UIDropDownMenu_CreateInfo()
		        info.isTitle = 1
		        info.text = L["Segment"]
		        UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Total"]
	            info.func = function()
	            				window.selectedset = "total"
	            				Skada:Wipe()
	            				Skada:UpdateDisplay(true)
	            			end
	            info.checked = (window.selectedset == "total")
	            UIDropDownMenu_AddButton(info, level)
                
                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Current"]
	            info.func = function()
	            				window.selectedset = "current"
	            				Skada:Wipe()
	            				Skada:UpdateDisplay(true)
	            			end
	            info.checked = (window.selectedset == "current")
	            UIDropDownMenu_AddButton(info, level)

		        for i, set in ipairs(Skada:GetSets()) do
			        wipe(info)
		            info.text = Skada:GetSetLabel(set)
		            info.func = function()
		            				window.selectedset = i
		            				Skada:Wipe()
		            				Skada:UpdateDisplay(true)
		            			end
		            info.checked = (window.selectedset == set.starttime)
		            UIDropDownMenu_AddButton(info, level)
		        end

		        -- Add a blank separator
                info = UIDropDownMenu_CreateInfo()
		        info.disabled = 1
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Lock window"]
	            info.func = function()
	            				window.db.barslocked = not window.db.barslocked
	            				Skada:ApplySettings()
	            			end
	            info.checked = window.db.barslocked
		        UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Hide window"]
	            info.func = function() if window:IsShown() then window.db.hidden = true; window:Hide() else window.db.hidden = false; window:Show() end end
	            info.checked = not window:IsShown()
		        UIDropDownMenu_AddButton(info, level)

		    elseif UIDROPDOWNMENU_MENU_VALUE == "delete" then
		        for i, set in ipairs(Skada:GetSets()) do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = Skada:GetSetLabel(set)
		            info.func = function() Skada:DeleteSet(set) end
			        info.notCheckable = 1
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "keep" then
		        for i, set in ipairs(Skada:GetSets()) do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = Skada:GetSetLabel(set)
		            info.func = function()
		            				set.keep = not set.keep
		            				Skada:Wipe()
		            				Skada:UpdateDisplay(true)
		            			end
		            info.checked = set.keep
		            UIDropDownMenu_AddButton(info, level)
		        end
		    end
		elseif level == 3 then
		    if UIDROPDOWNMENU_MENU_VALUE == "modes" then

		        for i, module in ipairs(Skada:GetModes()) do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = module:GetName()
		            info.checked = (Skada.db.profile.report.mode == module:GetName())
		            info.func = function() Skada.db.profile.report.mode = module:GetName() end
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "segment" then
                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Total"]
	            info.func = function() Skada.db.profile.report.set = "total" end
	            info.checked = (Skada.db.profile.report.set == "total")
	            UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
	            info.text = L["Current"]
	            info.func = function() Skada.db.profile.report.set = "current" end
	            info.checked = (Skada.db.profile.report.set == "current")
	            UIDropDownMenu_AddButton(info, level)

		        for i, set in ipairs(Skada:GetSets()) do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = Skada:GetSetLabel(set)
		            info.func = function() Skada.db.profile.report.set = i end
		            info.checked = (Skada.db.profile.report.set == i)
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "number" then
		        for i = 1,25 do
                    info = UIDropDownMenu_CreateInfo()
		            info.text = i
		            info.checked = (Skada.db.profile.report.number == i)
		            info.func = function() Skada.db.profile.report.number = i end
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "channel" then
                info = UIDropDownMenu_CreateInfo()
		        info.text = L["Whisper"]
		        info.checked = (Skada.db.profile.report.chantype == "whisper")
		        info.func = function() Skada.db.profile.report.channel = "Whisper"; Skada.db.profile.report.chantype = "whisper" end
		        UIDropDownMenu_AddButton(info, level)

		        info.text = L["Say"]
		        info.checked = (Skada.db.profile.report.channel == "Say")
		        info.func = function() Skada.db.profile.report.channel = "Say"; Skada.db.profile.report.chantype = "preset" end
		        UIDropDownMenu_AddButton(info, level)

	            info.text = L["Raid"]
	            info.checked = (Skada.db.profile.report.channel == "Raid")
	            info.func = function() Skada.db.profile.report.channel = "Raid"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Party"]
	            info.checked = (Skada.db.profile.report.channel == "Party")
	            info.func = function() Skada.db.profile.report.channel = "Party"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Instance"]
	            info.checked = (Skada.db.profile.report.channel == "INSTANCE_CHAT")
	            info.func = function() Skada.db.profile.report.channel = "INSTANCE_CHAT"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Guild"]
	            info.checked = (Skada.db.profile.report.channel == "Guild")
	            info.func = function() Skada.db.profile.report.channel = "Guild"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Officer"]
	            info.checked = (Skada.db.profile.report.channel == "Officer")
	            info.func = function() Skada.db.profile.report.channel = "Officer"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Self"]
	            info.checked = (Skada.db.profile.report.chantype == "self")
	            info.func = function() Skada.db.profile.report.channel = "Self"; Skada.db.profile.report.chantype = "self" end
	            UIDropDownMenu_AddButton(info, level)

				info.text = BATTLENET_OPTIONS_LABEL
				info.checked = (Skada.db.profile.report.chantype == "bnet")
				info.func = function() Skada.db.profile.report.channel = "bnet"; Skada.db.profile.report.chantype = "bnet" end
				UIDropDownMenu_AddButton(info, level)

				local list = {GetChannelList()}
				for i=1,table.getn(list)/2 do
					info.text = list[i*2]
					info.checked = (Skada.db.profile.report.channel == list[i*2])
					info.func = function() Skada.db.profile.report.channel = list[i*2]; Skada.db.profile.report.chantype = "channel" end
					UIDropDownMenu_AddButton(info, level)
				end

		    end

	    end
	end

	local x,y;
	skadamenu.point, x, y = getDropdownPoint()
	ToggleDropDownMenu(1, nil, skadamenu, "UIParent", x, y)
end

function Skada:SegmentMenu(window)
	if not self.segmentsmenu then
		self.segmentsmenu = CreateFrame("Frame", "SkadaWindowButtonsSegments")
	end
	local segmentsmenu = self.segmentsmenu

	segmentsmenu.displayMode = "MENU"
	segmentsmenu.initialize = function(self, level)
	    if not level then return end

        local info = UIDropDownMenu_CreateInfo()
		info.isTitle = 1
		info.text = L["Segment"]
		UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
		info.text = L["Total"]
		info.func = function()
						window.selectedset = "total"
	            				Skada:Wipe()
						Skada:UpdateDisplay(true)
					end
		info.checked = (window.selectedset == "total")
		UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
		info.text = L["Current"]
		info.func = function()
						window.selectedset = "current"
	            				Skada:Wipe()
						Skada:UpdateDisplay(true)
					end
		info.checked = (window.selectedset == "current")
		UIDropDownMenu_AddButton(info, level)

		for i, set in ipairs(Skada:GetSets()) do
            info = UIDropDownMenu_CreateInfo()
			info.text = Skada:GetSetLabel(set)
			info.func = function()
							window.selectedset = i
	            					Skada:Wipe()
							Skada:UpdateDisplay(true)
						end
			info.checked = (window.selectedset == i)
			UIDropDownMenu_AddButton(info, level)
		end
	end
	local x,y;
	segmentsmenu.point, x, y = getDropdownPoint()
	ToggleDropDownMenu(1, nil, segmentsmenu, "UIParent", x, y)
end

function Skada:ModeMenu(window)
	--Spew("window", window)
	if not self.modesmenu then
		self.modesmenu = CreateFrame("Frame", "SkadaWindowButtonsModes")
	end
	local modesmenu = self.modesmenu

	modesmenu.displayMode = "MENU"
	modesmenu.initialize = function(self, level)
	    if not level then return end

        _modeMenu(window, level)
	end
	local x,y;
	modesmenu.point, x, y = getDropdownPoint()
	ToggleDropDownMenu(1, nil, modesmenu, "UIParent", x, y)
end

function Skada:OpenReportWindow(window)
	if self.ReportWindow==nil then
		self:CreateReportWindow(window)
	end

	--self:UpdateReportWindow()
	self.ReportWindow:Show()
end

local function destroywindow()
	if Skada.ReportWindow then
		-- remove AceGUI hacks before recycling the widget
		local frame = Skada.ReportWindow
		frame.LayoutFinished = frame.orig_LayoutFinished
		frame.frame:SetScript("OnKeyDown", nil)
		frame.frame:EnableKeyboard(false)
		frame.frame:SetPropagateKeyboardInput(false)


		frame:ReleaseChildren()
		frame:Release()
	end
	Skada.ReportWindow = nil
end

function Skada:CreateReportWindow(window)
	-- ASDF = window
	self.ReportWindow = AceGUI:Create("Window")
	local frame = self.ReportWindow
	frame:EnableResize(false)
	frame:SetWidth(250)
	frame:SetLayout("List")
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	frame.frame:SetClampedToScreen(true)

	-- slight AceGUI hack to auto-set height of Window widget:
	frame.orig_LayoutFinished = frame.LayoutFinished
	frame.LayoutFinished = function(self, _, height) frame:SetHeight(height + 57) end
	-- another AceGUI hack to hide on Escape:
  	frame.frame:SetScript("OnKeyDown", function(self,key)
        	if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
			destroywindow()
		end
	end)
	frame.frame:EnableKeyboard(true)
	frame.frame:SetPropagateKeyboardInput(true)


	if window then
		frame:SetTitle(L["Report"] .. (" - %s"):format(window.db.name))
	else
		frame:SetTitle(L["Report"])
	end
	frame:SetCallback("OnClose", function(widget, callback) destroywindow() end)

	if window then
		Skada.db.profile.report.set = window.selectedset
		Skada.db.profile.report.mode = window.db.mode
	else
		-- Mode, default last chosen or first available.
		local modebox = AceGUI:Create("Dropdown")
		modebox:SetLabel(L["Mode"])
		modebox:SetList({})
		for i, mode in ipairs(Skada:GetModes()) do
			modebox:AddItem(mode:GetName(), mode:GetName())
		end
		modebox:SetCallback("OnValueChanged", function(f, e, value) Skada.db.profile.report.mode = value end)
		modebox:SetValue(Skada.db.profile.report.mode or Skada:GetModes()[1])
		frame:AddChild(modebox)

		-- Segment, default last chosen or last set.
		local setbox = AceGUI:Create("Dropdown")
		setbox:SetLabel(L["Segment"])
		setbox:SetList({total = L["Total"], current = L["Current"]})
		for i, set in ipairs(Skada:GetSets()) do
			setbox:AddItem(i, (Skada:GetSetLabel(set)))
		end
		setbox:SetCallback("OnValueChanged", function(f, e, value) Skada.db.profile.report.set = value end)
		setbox:SetValue(Skada.db.profile.report.set or Skada:GetSets()[1])
		frame:AddChild(setbox)
	end

	local channellist = {
		whisper 	= { L["Whisper"], "whisper", true},
		target		= { L["Whisper Target"], "whisper"},
		say			= { L["Say"], "preset"},
		raid 		= { L["Raid"], "preset"},
		party 		= { L["Party"], "preset"},
		instance_chat 		= { L["Instance"], "preset"},
		guild 		= { L["Guild"], "preset"},
		officer 	= { L["Officer"], "preset"},
		self 		= { L["Self"], "self"},
		bnet	 	= { BATTLENET_OPTIONS_LABEL, "bnet", true},
	}
	local list = {GetChannelList()}
	for i=1,#list/2 do
		local chan = list[i*2]
		if chan ~= "Trade" and chan ~= "General" and chan ~= "LookingForGroup" then -- These should be localized.
			channellist[chan] = {chan, "channel"}
		end
	end

	-- Channel, default last chosen or Say.
	local channelbox = AceGUI:Create("Dropdown")
	channelbox:SetLabel(L["Channel"])
	channelbox:SetList( {} )
	for chan, kind in pairs(channellist) do
		channelbox:AddItem(chan, kind[1])
	end
	local origchan = Skada.db.profile.report.channel or "say"
	if not channellist[origchan] then origchan = "say" end -- ticket 455: upgrading old settings
	channelbox:SetValue(origchan)
	channelbox:SetCallback("OnValueChanged", function(f, e, value)
				Skada.db.profile.report.channel = value
				Skada.db.profile.report.chantype = channellist[value][2]
				if channellist[origchan][3] ~= channellist[value][3] then
					-- redraw in-place to add/remove whisper widget
					local pos = { frame:GetPoint() }
					destroywindow() 
					Skada:CreateReportWindow(window)
					Skada.ReportWindow:SetPoint(unpack(pos))
				end
	end)
	frame:AddChild(channelbox)

	local lines = AceGUI:Create("Slider")
	lines:SetLabel(L["Lines"])
	lines:SetValue(Skada.db.profile.report.number ~= nil and Skada.db.profile.report.number	 or 10)
	lines:SetSliderValues(1, 25, 1)
	lines:SetCallback("OnValueChanged", function(self, event, value) Skada.db.profile.report.number = value end)
	lines:SetFullWidth(true)
	frame:AddChild(lines)

	if channellist[origchan][3] then
		local whisperbox = AceGUI:Create("EditBox")
		whisperbox:SetLabel(L["Whisper Target"])
		whisperbox:SetText(Skada.db.profile.report.target or "")
		whisperbox:SetCallback("OnEnterPressed", function(box, event, text) 
			if strlenutf8(text) == #text then -- remove spaces which are always non-meaningful and can sometimes cause problems
				local ntext = text:gsub("%s","")
				if ntext ~= text then
					text = ntext
					whisperbox:SetText(text)
				end
			end
			Skada.db.profile.report.target = text; 
			frame.button.frame:Click() 
		end)
		whisperbox:SetCallback("OnTextChanged", function(box, event, text) Skada.db.profile.report.target = text end)
		whisperbox:SetFullWidth(true)
		frame:AddChild(whisperbox)
	end

	local report = AceGUI:Create("Button")
	frame.button = report
	report:SetText(L["Report"])
	report:SetCallback("OnClick", function()
		local mode, set, channel, chantype, number = Skada.db.profile.report.mode, Skada.db.profile.report.set, Skada.db.profile.report.channel, Skada.db.profile.report.chantype, Skada.db.profile.report.number

		if channel == "whisper" then
			channel = Skada.db.profile.report.target
			if channel and #strtrim(channel) == 0 then
				channel = nil
			end
		elseif channel == "bnet" then
			channel = BNet_GetBNetIDAccount(Skada.db.profile.report.target)
		elseif channel == "target" then
			if UnitExists("target") then
				local toon, realm = UnitName("target")
				if realm and #realm > 0 then
					channel = toon .. "-" .. realm
				else
					channel = toon
				end
			else
				channel = nil
			end
		end
		-- print(tostring(frame.channel), tostring(frame.chantype), tostring(window.db.mode))

		if channel and chantype and mode and set and number then
			Skada:Report(channel, chantype, mode, set, number, window)
			frame:Hide()
		else
			Skada:Print("Error: Whisper target not found")
		end

	end)
	report:SetFullWidth(true)
	frame:AddChild(report)
end
