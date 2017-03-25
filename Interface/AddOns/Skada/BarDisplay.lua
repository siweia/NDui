--[[

The traditional bar display used in some form by most damage meters.

--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Skada", false)

local Skada = Skada

local mod = Skada:NewModule("BarDisplay", "SpecializedLibBars-1.0")
local libwindow = LibStub("LibWindow-1.1")
local media = LibStub("LibSharedMedia-3.0")

-- Aliases
local table_sort = _G.table.sort
local next, pairs, ipairs, type = next, pairs, ipairs, type

--
-- Display implementation.
--

-- Add to Skada's enormous list of display providers.
mod.name = L["Bar display"]
mod.description = L["Bar display is the normal bar window used by most damage meters. It can be extensively styled."]
Skada:AddDisplaySystem("bar", mod)

-- Called when a Skada window starts using this display provider.
function mod:Create(window)
	-- Re-use bargroup if it exists.
	window.bargroup = mod:GetBarGroup(window.db.name)

	-- Save a reference to window in bar group. Needed for some nasty callbacks.
	if window.bargroup then
		-- Clear callbacks.
		window.bargroup.callbacks = LibStub:GetLibrary("CallbackHandler-1.0"):New(window.bargroup)
	else
		window.bargroup = mod:NewBarGroup(window.db.name, nil, window.db.background.height, window.db.barwidth, window.db.barheight, "SkadaBarWindow"..window.db.name)
		local bargroup = window.bargroup -- ticket 323

		-- Add window buttons.
		window.bargroup:AddButton(L["Configure"], L["Configure description"], "Interface\\Buttons\\UI-OptionsButton", "Interface\\Buttons\\UI-OptionsButton", function() Skada:OpenMenu(bargroup.win) end)
		window.bargroup:AddButton(L["Reset"], L["Reset description"], "Interface\\Buttons\\UI-StopButton", "Interface\\Buttons\\UI-StopButton", function() Skada:ShowPopup() end)
		window.bargroup:AddButton(L["Segment"], L["Segment description"], "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", function() Skada:SegmentMenu(bargroup.win) end)
		window.bargroup:AddButton(L["Mode"], L["Mode description"], "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", function() Skada:ModeMenu(bargroup.win) end)
		window.bargroup:AddButton(L["Report"], L["Report description"], "Interface\\Buttons\\UI-GuildButton-MOTD-Up", "Interface\\Buttons\\UI-GuildButton-MOTD-Up", function() Skada:OpenReportWindow(bargroup.win) end)
		window.bargroup:AddButton(L["Stop"], L["Stop description"], "Interface\\Buttons\\Arrow-Down-Down", "Interface\\Buttons\\Arrow-Down-Down", function()
            if Skada.current and Skada.current.stopped then
                Skada:ResumeSegment();
            elseif Skada.current then
                Skada:StopSegment()
            end
        end)
	end
	window.bargroup.win = window
	window.bargroup.RegisterCallback(mod, "AnchorMoved")
	window.bargroup.RegisterCallback(mod, "WindowResized")
	window.bargroup:EnableMouse(true)
	window.bargroup:SetScript("OnMouseDown", function(win, button) if IsShiftKeyDown() then Skada:OpenMenu(window) elseif button == "RightButton" then window:RightClick() end end)
	window.bargroup.button:SetScript("OnClick", function(win, button) if IsShiftKeyDown() then Skada:OpenMenu(window) elseif button == "RightButton" then window:RightClick() end end)
    
	window.bargroup.button:SetScript("OnEnter", function(win, button)
        window.bargroup:SetButtonsOpacity(1.0)
    end)
	window.bargroup.button:SetScript("OnLeave", function(win, button)
        if not window.bargroup.button:IsMouseOver() then
            window.bargroup:SetButtonsOpacity(0.25)
        end
    end)
    
	window.bargroup:HideIcon()

    window.bargroup.button:GetFontString():SetWordWrap(false);
	window.bargroup.button:GetFontString():SetPoint("LEFT", window.bargroup.button, "LEFT", 5, 1)
	window.bargroup.button:GetFontString():SetJustifyH("LEFT")
	window.bargroup.button:SetHeight(window.db.title.height or 15)

	-- Register with LibWindow-1.0.
	libwindow.RegisterConfig(window.bargroup, window.db)

	-- Restore window position.
	libwindow.RestorePosition(window.bargroup)

	if not mod.class_icon_tcoords then -- amortized class icon coordinate adjustment
		mod.class_icon_tcoords = {}
		for class, coords in pairs(CLASS_ICON_TCOORDS) do
			local l,r,t,b = unpack(coords)
			local adj = 0.02
			mod.class_icon_tcoords[class] = {(l+adj),(r-adj),(t+adj),(b-adj)}
		end
	end
    
    if not mod.role_icon_tcoords then
        mod.role_icon_tcoords = {
            DAMAGER = {0.3125, 0.63, 0.3125, 0.63},
            HEALER  = {0.3125, 0.63, 0.015625, 0.3125},
            TANK    = {0, 0.296875, 0.3125, 0.63},
            LEADER  = {0, 0.296875, 0.015625, 0.3125},
            NONE    = ""
        }
    end
    
end

-- Called by Skada windows when the window is to be destroyed/cleared.
function mod:Destroy(win)
	win.bargroup:Hide()
	win.bargroup = nil
end

-- Called by Skada windows when the window is to be completely cleared and prepared for new data.
function mod:Wipe(win)
	-- Reset sort function.
	win.bargroup:SetSortFunction(nil)

	-- Reset scroll offset.
	win.bargroup:SetBarOffset(0)

	-- Remove the bars.
	local bars = win.bargroup:GetBars()
	if bars then
		for i, bar in pairs(bars) do
			bar:Hide()
			win.bargroup:RemoveBar(bar)
		end
	end

	-- Clean up.
	win.bargroup:SortBars()
end

local function showmode(win, id, label, mode)
	-- Add current mode to window traversal history.
	if win.selectedmode then
		tinsert(win.history, win.selectedmode)
	end
	-- Call the Enter function on the mode.
	if mode.Enter then
		mode:Enter(win, id, label)
	end
	-- Display mode.
	win:DisplayMode(mode)
end

local function BarClickIgnore(bar, button)
	local win = bar.win
	if button == "RightButton" then 
		win:RightClick() 
	end
end

local function BarClick(bar, button)
	local win, id, label = bar.win, bar.id, bar.text
	local click1 = win.metadata.click1
	local click2 = win.metadata.click2
	local click3 = win.metadata.click3

	if button == "RightButton" and IsShiftKeyDown() then
		Skada:OpenMenu(win)
	elseif win.metadata.click then
		win.metadata.click(win, id, label, button)
	elseif button == "RightButton" then
		win:RightClick()
	elseif click2 and IsShiftKeyDown() then
		showmode(win, id, label, click2)
	elseif click3 and IsControlKeyDown() then
		showmode(win, id, label, click3)
	elseif click1 then
		showmode(win, id, label, click1)
	end
end

local ttactive = false

local function BarEnter(bar)
	local win, id, label = bar.win, bar.id, bar.text
    ttactive = true
    Skada:SetTooltipPosition(GameTooltip, win.bargroup)
    Skada:ShowTooltip(win, id, label)
end

local function BarLeave(bar)
	local win, id, label = bar.win, bar.id, bar.text
	if ttactive then
		GameTooltip:Hide()
		ttactive = false
	end
end

local function BarResize(bar)
	if bar.bgwidth then
		bar.bgtexture:SetWidth(bar.bgwidth * bar:GetWidth())
	else
		bar:SetScript("OnSizeChanged",bar.OnSizeChanged)
	end
	bar:OnSizeChanged() -- call library version
end

local function BarIconEnter(icon)
	local bar = icon.bar
	local win = bar.win
	if bar.link and win and win.bargroup then
		Skada:SetTooltipPosition(GameTooltip, win.bargroup); 
		GameTooltip:SetHyperlink(bar.link); 
		GameTooltip:Show();
	end
end

local function BarIconMouseDown(icon) -- shift-click to link spell into chat
	local bar = icon.bar
	if not IsShiftKeyDown() or not bar.link then return end
	local activeEditBox = ChatEdit_GetActiveWindow()
	if activeEditBox then
		ChatEdit_InsertLink(bar.link)
	else
		ChatFrame_OpenChat(bar.link, DEFAULT_CHAT_FRAME)
	end
end

local function value_sort(a,b)
	if not a or a.value == nil then
		return false
	elseif not b or b.value == nil then
		return true
	else
		return a.value > b.value
	end
end

local function bar_order_sort(a,b)
	return a and b and a.order and b.order and a.order < b.order
end

local function HideGameTooltip()
	GameTooltip:Hide()
end

-- Called by Skada windows when title of window should change.
function mod:SetTitle(win, title)
	-- Set title.
	win.bargroup.button:SetText(title)
end

-- Called by Skada windows when the display should be updated to match the dataset.
function mod:Update(win)
	-- Some modes may alter title continously.
	win.bargroup.button:SetText(win.metadata.title)

	-- Sort if we are showing spots with "showspots".
	if win.metadata.showspots then
		table_sort(win.dataset, value_sort)
	end

	-- Find out if we have icons in this update, and if so, adjust accordingly.
	local hasicon = false
	for i, data in ipairs(win.dataset) do
		if (data.icon and not data.ignore) or (data.class and win.db.classicons) or (data.role and win.db.roleicons) then
			hasicon = true
		end
	end

	if hasicon and not win.bargroup.showIcon then
		win.bargroup:ShowIcon()
	end
	if not hasicon and win.bargroup.showIcon then
		win.bargroup:HideIcon()
	end

	-- If we are using "wipestale", we may have removed data
	-- and we need to remove unused bars.
	-- The Threat module uses this.
	-- For each bar, mark bar as unchecked.
	if win.metadata.wipestale then
		local bars = win.bargroup:GetBars()
		if bars then
			for name, bar in pairs(bars) do
				bar.checked = false
			end
		end
	end

	local nr = 1
	for i, data in ipairs(win.dataset) do
		if data.id then
			local barid = data.id
			local barlabel = data.label

			local bar = win.bargroup:GetBar(barid)

			if bar and bar.missingclass and data.class and not data.ignore then
			        -- fixup bar that was generated before class info was available
				bar:Hide()
				win.bargroup:RemoveBar(bar)
				bar.missingclass = nil
				bar = nil
			end

			if bar then
				bar:SetValue(data.value)
				bar:SetMaxValue(win.metadata.maxvalue or 1) -- MUST come after SetValue
			else
				-- Initialization of bars.
				bar = mod:CreateBar(win, barid, barlabel, data.value, win.metadata.maxvalue or 1, data.icon, false)
				bar.id = barid
				bar.text = barlabel
                bar.fixed = false
				if not data.ignore then

					if data.icon then
						bar:ShowIcon()

						bar.link = nil
						if data.spellid then
							local spell = data.spellid
							bar.link = GetSpellLink(spell)
						elseif data.hyperlink then
							bar.link = data.hyperlink
						end
						if bar.link then
							bar.iconFrame.bar = bar
							bar.iconFrame:EnableMouse(true)
							bar.iconFrame:SetScript("OnEnter", BarIconEnter)
							bar.iconFrame:SetScript("OnLeave", HideGameTooltip)
							bar.iconFrame:SetScript("OnMouseDown", BarIconMouseDown)
						end
					end

					bar:EnableMouse(true)
					bar:SetScript("OnEnter", BarEnter)
					bar:SetScript("OnLeave", BarLeave)
					bar:SetScript("OnMouseDown", BarClick)
				else
					bar:SetScript("OnEnter", nil)
					bar:SetScript("OnLeave", nil)
					bar:SetScript("OnMouseDown", BarClickIgnore)
				end
				bar:SetValue(data.value)

				if not data.class and
				   (win.db.classicons or win.db.classcolorbars or win.db.classcolortext) then
					bar.missingclass = true
				else
					bar.missingclass = nil
				end
                
				if data.role and data.role ~= "NONE" and win.db.roleicons then
					bar:ShowIcon()
                    --bar:SetIconWithCoord("Interface\\LFGFrame\\UI-LFG-ICON-ROLES", GetTexCoordsForRole(data.role))
                    bar:SetIconWithCoord("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES", mod.role_icon_tcoords[data.role])
                elseif data.class and win.db.classicons and mod.class_icon_tcoords[data.class] then
					bar:ShowIcon()
					bar:SetIconWithCoord("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes", mod.class_icon_tcoords[data.class])
				end
                    
				if data.color then
					-- Explicit color from dataset.
					bar:SetColorAt(0, data.color.r, data.color.g, data.color.b, data.color.a or 1)
                elseif data.spellschool and win.db.spellschoolcolors then
                    local colorfunc = _G.CombatLog_Color_ColorArrayBySchool
                    if colorfunc then
                       local color = colorfunc(data.spellschool)
					   bar:SetColorAt(0, color.r, color.g, color.b, color.a or 1)
                    end
				elseif data.class and win.db.classcolorbars then
					-- Class color.
					local color = Skada.classcolors[data.class]
					if color then
						bar:SetColorAt(0, color.r, color.g, color.b, color.a or 1)
					end
				else
					-- Default color.
					local color = win.db.barcolor
					bar:SetColorAt(0, color.r, color.g, color.b, color.a or 1)
				end

				if data.class and win.db.classcolortext then
					-- Class color text.
					local color = Skada.classcolors[data.class]
					if color then
						bar.label:SetTextColor(color.r, color.g, color.b, color.a or 1)
						bar.timerLabel:SetTextColor(color.r, color.g, color.b, color.a or 1)
					end
				else
					-- Default color text.
					bar.label:SetTextColor(1,1,1,1)
					bar.timerLabel:SetTextColor(1,1,1,1)
				end
                
                if Skada.db.profile.showself and data.id and data.id == UnitGUID("player") then
                    -- Always show self
                    bar.fixed = true
                end
			end

            if win.metadata.ordersort then
				bar.order = i
			end

			if win.metadata.showspots and Skada.db.profile.showranks and not data.ignore then
                if win.db.barorientation == 1 then
                    bar:SetLabel(("%2u. %s"):format(nr, data.label))
                else
                    bar:SetLabel(("%s %2u"):format(data.label, nr))
                end
			else
				bar:SetLabel(data.label)
			end
			bar:SetTimerLabel(data.valuetext)

			if win.metadata.wipestale then
				bar.checked = true
			end

			-- Emphathized items - cache a flag saying it is done so it is not done again.
			-- This is a little lame.
			if data.emphathize and bar.emphathize_set ~= true then
				bar:SetFont(nil,nil,"OUTLINE")
				bar.emphathize_set = true
			elseif not data.emphathize and bar.emphathize_set ~= false then
				bar:SetFont(nil,nil, win.db.barfontflags)
				bar.emphathize_set = false
			end

			-- Background texture color.
			if data.backgroundcolor then
				bar.bgtexture:SetVertexColor(data.backgroundcolor.r, data.backgroundcolor.g, data.backgroundcolor.b, data.backgroundcolor.a or 1)
			end

			-- Background texture size (in percent, as the mode has no idea on actual widths).
			if data.backgroundwidth then
				bar.bgtexture:ClearAllPoints()
				bar.bgtexture:SetPoint("BOTTOMLEFT")
				bar.bgtexture:SetPoint("TOPLEFT")
				bar.bgwidth = data.backgroundwidth
				bar:SetScript("OnSizeChanged",BarResize) -- ticket 365: required to resize bgtexture
				BarResize(bar)
			else
				bar.bgwidth = nil
			end

			if not data.ignore then
				nr = nr + 1
			end
		end
	end

	-- If we are using "wipestale", remove all unchecked bars.
	if win.metadata.wipestale then
		local bars = win.bargroup:GetBars()
		for name, bar in pairs(bars) do
			if not bar.checked then
				win.bargroup:RemoveBar(bar)
			end
		end
	end

	-- Sort by the order in the data table if we are using "ordersort".
	if win.metadata.ordersort then
		win.bargroup:SetSortFunction(bar_order_sort)
		win.bargroup:SortBars()
	else
		win.bargroup:SetSortFunction(nil)
		win.bargroup:SortBars()
	end

end

function mod:AnchorMoved(cbk, group, x, y)
	libwindow.SavePosition(group)
end

function mod:WindowResized(cbk, group)
	libwindow.SavePosition(group)

	-- Also save size.
	group.win.db.background.height = group:GetHeight()
	group.win.db.barwidth = group:GetWidth()
end

function mod:Show(win)
	win.bargroup:Show()
	win.bargroup:SortBars()
end

function mod:Hide(win)
	win.bargroup:Hide()
end

function mod:IsShown(win)
	return win.bargroup:IsShown()
end

local function getNumberOfBars(win)
	local bars = win.bargroup:GetBars()
	local n = 0
	for i, bar in pairs(bars) do n = n + 1 end
	return n
end

local function OnMouseWheel(frame, direction)
	local win = frame.win
	local maxbars = win.db.background.height / (win.db.barheight + win.db.barspacing)
	if direction == 1 and win.bargroup:GetBarOffset() > 0 then
		win.bargroup:SetBarOffset(win.bargroup:GetBarOffset() - 1)
	elseif direction == -1 and ((getNumberOfBars(win) - maxbars - win.bargroup:GetBarOffset()) > 0) then
		win.bargroup:SetBarOffset(win.bargroup:GetBarOffset() + 1)
	end
end

function mod:OnMouseWheel(win, frame, direction) -- external scrolling interface (SkadaScroll)
	if not frame then
		mod.framedummy = mod.framedummy or {}
		mod.framedummy.win = win
		frame = mod.framedummy
	end
	OnMouseWheel(frame, direction)
end

function mod:CreateBar(win, name, label, value, maxvalue, icon, o)
	local bar = win.bargroup:NewCounterBar(name, label, value, maxvalue, icon)
	bar.win = win
	bar:EnableMouseWheel(true)
	bar:SetScript("OnMouseWheel", OnMouseWheel)
	bar.iconFrame:SetScript("OnEnter", nil)
	bar.iconFrame:SetScript("OnLeave", nil)
	bar.iconFrame:SetScript("OnMouseDown", nil)
	bar.iconFrame:EnableMouse(false)
	return bar
end

local titlebackdrop = {}
local windowbackdrop = {}

-- Called by Skada windows when window settings have changed.
function mod:ApplySettings(win)
	local g = win.bargroup
    g:SetFrameLevel(1)
	local p = win.db
	g:ReverseGrowth(p.reversegrowth)
	g:SetOrientation(p.barorientation)
	g:SetBarHeight(p.barheight)
	g:SetHeight(p.background.height)
	g:SetWidth(p.barwidth)
	g:SetLength(p.barwidth)
	g:SetTexture(p.bartexturepath or media:Fetch('statusbar', p.bartexture))

	g:SetBarBackgroundColor(p.barbgcolor.r, p.barbgcolor.g, p.barbgcolor.b, p.barbgcolor.a or 0.6)
	g:SetFont(p.barfontpath or media:Fetch('font', p.barfont), p.barfontsize, p.barfontflags)
	g:SetSpacing(p.barspacing)
	g:UnsetAllColors()
	g:SetColorAt(0,p.barcolor.r,p.barcolor.g,p.barcolor.b, p.barcolor.a)
	if p.barslocked then
		g:Lock()
	else
		g:Unlock()
	end

    if p.strata then g:SetFrameStrata(p.strata) end
    
	-- Header
	local fo = CreateFont("TitleFont"..win.db.name)
	fo:SetFont(p.title.fontpath or media:Fetch('font', p.title.font), p.title.fontsize, p.title.fontflags)
    if p.title.textcolor then
        fo:SetTextColor(p.title.textcolor.r, p.title.textcolor.g, p.title.textcolor.b, p.title.textcolor.a)
    end
	g.button:SetNormalFontObject(fo)

	titlebackdrop.bgFile = media:Fetch("statusbar", p.title.texture)
	titlebackdrop.tile = false
	titlebackdrop.tileSize = 0
	titlebackdrop.edgeSize = p.title.borderthickness
	g.button:SetBackdrop(titlebackdrop)
	local color = p.title.color
	g.button:SetBackdropColor(color.r, color.g, color.b, color.a or 1)
	g.button:SetHeight(p.title.height or 15)

    Skada:ApplyBorder(g.button, p.title.bordertexture, p.title.bordercolor, p.title.borderthickness)
    
	if p.enabletitle then
		g:ShowAnchor()
	else
		g:HideAnchor()
	end

	-- Adjust button positions
	g:AdjustButtons()

	-- Button visibility.
	g:ShowButton(L["Configure"], p.buttons.menu)
	g:ShowButton(L["Reset"], p.buttons.reset)
	g:ShowButton(L["Mode"], p.buttons.mode)
	g:ShowButton(L["Segment"], p.buttons.segment)
	g:ShowButton(L["Report"], p.buttons.report)
	g:ShowButton(L["Stop"], p.buttons.stop)

	-- Window
    local padtop = (p.enabletitle and not p.reversegrowth and p.title.height)
    local padbottom = (p.enabletitle and p.reversegrowth and p.title.height)
    Skada:ApplyBorder(g, p.background.bordertexture, p.background.bordercolor, p.background.borderthickness, padtop, padbottom)
    
	windowbackdrop.bgFile = p.background.texturepath or media:Fetch("background", p.background.texture)
	windowbackdrop.tile = false
	windowbackdrop.tileSize = 0
	g:SetBackdrop(windowbackdrop)
    
	local color = p.background.color
	g:SetBackdropColor(color.r, color.g, color.b, color.a or 1)

	-- Clickthrough
	g:SetEnableMouse(not p.clickthrough)

	-- Scale
	g:SetScale(p.scale)
    
    -- Smoothing
    g:SetSmoothing(p.smoothing)

	libwindow.SavePosition(g)

	g:SortBars()
end

--
-- Options.
--

function mod:AddDisplayOptions(win, options)
	local db = win.db

	options.baroptions = {
		type = "group",
		name = L["Bars"],
		order=1,
		args = {

		    barfont = {
		         type = 'select',
		         dialogControl = 'LSM30_Font',
		         name = L["Bar font"],
		         desc = L["The font used by all bars."],
		         values = AceGUIWidgetLSMlists.font,
		         get = function() return db.barfont end,
		         set = function(win,key)
		         			db.barfont = key
		         			Skada:ApplySettings()
						end,
				order=1,
		    },

			barfontsize = {
				type="range",
				name=L["Bar font size"],
				desc=L["The font size of all bars."],
				min=7,
				max=40,
				step=1,
				get=function() return db.barfontsize end,
				set=function(win, size)
							db.barfontsize = size
		         			Skada:ApplySettings()
						end,
				order=2,
			},

		    barfontflags = {
		         type = 'select',
		         name = L["Font flags"],
		         desc = L["Sets the font flags."],
		         values = {[""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick outline"], ["MONOCHROME"] = L["Monochrome"], ["OUTLINEMONOCHROME"] = L["Outlined monochrome"]},
		         get = function() return db.barfontflags end,
		         set = function(win,key)
		         			db.barfontflags = key
		         			Skada:ApplySettings()
						end,
				order=3,
		    },

		    bartexture = {
		         type = 'select',
		         dialogControl = 'LSM30_Statusbar',
		         name = L["Bar texture"],
		         desc = L["The texture used by all bars."],
		         values = AceGUIWidgetLSMlists.statusbar,
		         get = function() return db.bartexture end,
		         set = function(win,key)
	         				db.bartexture = key
		         			Skada:ApplySettings()
						end,
				order=12,
		    },

			barspacing = {
				type="range",
				name=L["Bar spacing"],
				desc=L["Distance between bars."],
				min=0,
				max=10,
				step=1,
				get=function() return db.barspacing end,
				set=function(win, spacing)
							db.barspacing = spacing
		         			Skada:ApplySettings()
						end,
				order=13,
			},

			barheight = {
				type="range",
				name=L["Bar height"],
				desc=L["The height of the bars."],
				min=10,
				max=40,
				step=1,
				get=function() return db.barheight end,
				set=function(win, height)
							db.barheight = height
		         			Skada:ApplySettings()
						end,
				order=14,
			},

			barorientation = {
				type="select",
				name=L["Bar orientation"],
				desc=L["The direction the bars are drawn in."],
				values=	function() return {[1] = L["Left to right"], [3] = L["Right to left"]} end,
				get=function() return db.barorientation end,
				set=function(win, orientation)
						db.barorientation = orientation
	         			Skada:ApplySettings()
					end,
				order=17,
			},

			reversegrowth = {
			        type="toggle",
			        name=L["Reverse bar growth"],
			        desc=L["Bars will grow up instead of down."],
			        order=19,
			        get=function() return db.reversegrowth end,
			        set=function()
			        		db.reversegrowth = not db.reversegrowth
		         			Skada:ApplySettings()
			        	end,
			},

			color = {
				type="color",
				name=L["Bar color"],
				desc=L["Choose the default color of the bars."],
				hasAlpha=true,
				get=function(i)
						local c = db.barcolor
						return c.r, c.g, c.b, c.a
					end,
				set=function(i, r,g,b,a)
						db.barcolor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						Skada:ApplySettings()
					end,
				order=21,
			},

			bgcolor = {
				type="color",
				name=L["Background color"],
				desc=L["Choose the background color of the bars."],
				hasAlpha=true,
				get=function(i) return db.barbgcolor.r, db.barbgcolor.g, db.barbgcolor.b, db.barbgcolor.a end,
				set=function(i, r,g,b,a) db.barbgcolor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}; Skada:ApplySettings() end,
				order=22,
			},

			classcolorbars = {
			        type="toggle",
			        name=L["Class color bars"],
			        desc=L["When possible, bars will be colored according to player class."],
			        order=30,
			        get=function() return db.classcolorbars end,
			        set=function()
			        		db.classcolorbars = not db.classcolorbars
		         			Skada:ApplySettings()
			        	end,
			},

			classcolortext = {
			        type="toggle",
			        name=L["Class color text"],
			        desc=L["When possible, bar text will be colored according to player class."],
			        order=31,
			        get=function() return db.classcolortext end,
			        set=function()
			        		db.classcolortext = not db.classcolortext
		         			Skada:ApplySettings()
			        	end,
			},

			classicons = {
			        type="toggle",
			        name=L["Class icons"],
			        desc=L["Use class icons where applicable."],
			        order=32,
			        get=function() return db.classicons end,
			        set=function()
			        		db.classicons = not db.classicons
		         			Skada:ApplySettings()
			        	end,
			},

			roleicons = {
			        type="toggle",
			        name=L["Role icons"],
			        desc=L["Use role icons where applicable."],
			        order=33,
			        get=function() return db.roleicons end,
			        set=function()
			        		db.roleicons = not db.roleicons
		         			Skada:ApplySettings()
			        	end,
			},
            
			spellschoolcolors = {
			        type="toggle",
			        name=L["Spell school colors"],
			        desc=L["Use spell school colors where applicable."],
			        order=33,
			        get=function() return db.spellschoolcolors end,
			        set=function()
			        		db.spellschoolcolors = not db.spellschoolcolors
		         			Skada:ApplySettings()
			        	end,
			},
                
			clickthrough = {
			        type="toggle",
			        name=L["Clickthrough"],
			        desc=L["Disables mouse clicks on bars."],
			        order=20,
			        get=function() return db.clickthrough end,
			        set=function()
			        		db.clickthrough = not db.clickthrough
		         			Skada:ApplySettings()
			        	end,
			},
            
			smoothing = {
			        type="toggle",
			        name=L["Smooth bars"],
			        desc=L["Animate bar changes smoothly rather than immediately."],
			        order=34,
			        get=function() return db.smoothing end,
			        set=function()
			        		db.smoothing = not db.smoothing
		         			Skada:ApplySettings()
			        	end,
			},

		}
	}

    options.titleoptions = {
		type = "group",
		name = L["Title bar"],
		order=2,
		args = {

			enable = {
			        type="toggle",
			        name=L["Enable"],
			        desc=L["Enables the title bar."],
			        order=0,
			        get=function() return db.enabletitle end,
			        set=function()
			        		db.enabletitle = not db.enabletitle
		         			Skada:ApplySettings()
			        	end,
			},

			titleset = {
			        type="toggle",
			        name=L["Include set"],
			        desc=L["Include set name in title bar"],
			        order=0.5,
			        get=function() return db.titleset end,
			        set=function()
			        		db.titleset = not db.titleset
		         			Skada:ApplySettings()
			        	end,
			},
			height = {
				type="range",
				name=L["Title height"],
				desc=L["The height of the title frame."],
				 order=1,
				min=10,
				max=50,
				step=1,
				get=function() return db.title.height end,
				set=function(win, val)
							db.title.height = val
		         			Skada:ApplySettings()
						end,
			},

		    font = {
		         type = 'select',
		         dialogControl = 'LSM30_Font',
		         name = L["Bar font"],
		         desc = L["The font used by all bars."],
		         values = AceGUIWidgetLSMlists.font,
				 order=2,
		         get = function() return db.title.font end,
		         set = function(win,key)
		         			db.title.font = key
		         			Skada:ApplySettings()
						end,
				order=2,
		    },

			fontsize = {
				type="range",
				name=L["Bar font size"],
				desc=L["The font size of all bars."],
				min=7,
				max=40,
				step=1,
				get=function() return db.title.fontsize end,
				set=function(win, size)
							db.title.fontsize = size
		         			Skada:ApplySettings()
						end,
				order=3,
			},

		    fontflags = {
		         type = 'select',
		         name = L["Font flags"],
		         desc = L["Sets the font flags."],
		         values = {[""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick outline"], ["MONOCHROME"] = L["Monochrome"], ["OUTLINEMONOCHROME"] = L["Outlined monochrome"]},
		         get = function() return db.title.fontflags end,
		         set = function(win,key)
		         			db.title.fontflags = key
		         			Skada:ApplySettings()
						end,
				order=4,
		    },

			textcolor = {
				type="color",
				name=L["Title color"],
				desc=L["The text color of the title."],
				hasAlpha=true,
				get=function(i)
						local c = db.title.textcolor or {r = 0.9, g = 0.9, b = 0.9, a = 1}
						return c.r, c.g, c.b, c.a
					end,
				set=function(i, r,g,b,a)
						db.title.textcolor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						Skada:ApplySettings()
					end,
				order=4.1,
			},
            
			texture = {
		         type = 'select',
		         dialogControl = 'LSM30_Statusbar',
		         name = L["Background texture"],
		         desc = L["The texture used as the background of the title."],
		         values = AceGUIWidgetLSMlists.statusbar,
		         get = function() return db.title.texture end,
		         set = function(win,key)
	         				db.title.texture = key
		         			Skada:ApplySettings()
						end,
				order=5,
		    },
                
			color = {
				type="color",
				name=L["Background color"],
				desc=L["The background color of the title."],
				hasAlpha=true,
				get=function(i)
						local c = db.title.color
						return c.r, c.g, c.b, c.a
					end,
				set=function(i, r,g,b,a)
						db.title.color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						Skada:ApplySettings()
					end,
				order=5.1,
			},
                
		    bordertexture = {
		         type = 'select',
		         dialogControl = 'LSM30_Border',
		         name = L["Border texture"],
		         desc = L["The texture used for the border of the title."],
		         values = AceGUIWidgetLSMlists.border,
		         get = function() return db.title.bordertexture end,
		         set = function(win,key)
	         				db.title.bordertexture = key
		         			Skada:ApplySettings()
						end,
				order=6,
		    },

                
			bordercolor = {
				type="color",
				name=L["Border color"],
				desc=L["The color used for the border."],
				hasAlpha=true,
				get=function(i)
						local c = db.title.bordercolor or {r = 0, g = 0, b = 0, a = 1}
						return c.r, c.g, c.b, c.a
					end,
				set=function(i, r,g,b,a)
						db.title.bordercolor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
						Skada:ApplySettings()
					end,
				order=6.1,
			},
                
			thickness = {
				type="range",
				name=L["Border thickness"],
				desc=L["The thickness of the borders."],
				min=0,
				max=50,
				step=0.5,
				get=function() return db.title.borderthickness end,
				set=function(win, val)
							db.title.borderthickness = val
		         			Skada:ApplySettings()
						end,
				order=6.2,
			},

			buttons = {
				type = "group",
				name = L["Buttons"],
				order=20,
				inline=true,
				args = {
						report = {
								type="toggle",
								name=L["Report"],
								order=1,
								get=function() return db.buttons.report == nil or db.buttons.report end,
								set=function()
										db.buttons.report = not db.buttons.report
										Skada:ApplySettings()
									end,
						},
						mode = {
								type="toggle",
								name=L["Mode"],
								order=2,
								get=function() return db.buttons.mode == nil or db.buttons.mode end,
								set=function()
										db.buttons.mode = not db.buttons.mode
										Skada:ApplySettings()
									end,
						},
						segment = {
								type="toggle",
								name=L["Segment"],
								order=3,
								get=function() return db.buttons.segment == nil or db.buttons.segment end,
								set=function()
										db.buttons.segment = not db.buttons.segment
										Skada:ApplySettings()
									end,
						},
						reset = {
								type="toggle",
								name=L["Reset"],
								order=4,
								get=function() return db.buttons.reset end,
								set=function()
										db.buttons.reset = not db.buttons.reset
										Skada:ApplySettings()
									end,
						},
						menu = {
								type="toggle",
								name=L["Configure"],
								order=5,
								get=function() return db.buttons.menu end,
								set=function()
										db.buttons.menu = not db.buttons.menu
										Skada:ApplySettings()
									end,
						},
						stop = {
								type="toggle",
								name=L["Stop"],
                                description=L["Stop description"],
								order=5,
								get=function() return db.buttons.stop end,
								set=function()
										db.buttons.stop = not db.buttons.stop
										Skada:ApplySettings()
									end,
						},
				}
			}
		}
	}

	options.windowoptions = Skada:FrameSettings(db, false)
end


