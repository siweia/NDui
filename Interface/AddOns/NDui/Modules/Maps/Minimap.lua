local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Maps")

local strmatch, strfind, strupper = string.match, string.find, string.upper
local select, pairs, ipairs, unpack = select, pairs, ipairs, unpack
local cr, cg, cb = DB.r, DB.g, DB.b

function module:CreatePulse()
	if not NDuiDB["Map"]["CombatPulse"] then return end

	local bg = B.CreateBDFrame(Minimap, nil, true)
	local anim = bg:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(.8)
	anim.fader:SetToAlpha(.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local function updateMinimapAnim(event)
		if event == "PLAYER_REGEN_DISABLED" then
			bg:SetBackdropBorderColor(1, 0, 0)
			anim:Play()
		elseif not InCombatLockdown() then
			if C_Calendar.GetNumPendingInvites() > 0 or MiniMapMailFrame:IsShown() then
				bg:SetBackdropBorderColor(1, 1, 0)
				anim:Play()
			else
				anim:Stop()
				bg:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
	B:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapAnim)
	B:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapAnim)
	B:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateMinimapAnim)
	B:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapAnim)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then return end
		anim:Stop()
		bg:SetBackdropBorderColor(0, 0, 0)
	end)
end

function module:ReskinRegions()
	-- Garrison
	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, 6, -6)
	hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
		self:GetNormalTexture():SetTexture(DB.garrTex)
		self:GetPushedTexture():SetTexture(DB.garrTex)
		self:GetHighlightTexture():SetTexture(DB.garrTex)
		self:SetSize(30, 30)

		if RecycleBinToggleButton and not RecycleBinToggleButton.settled then
			RecycleBinToggleButton:SetPoint("BOTTOMRIGHT", -15, -6)
			RecycleBinToggleButton.settled = true
		end
	end)
	if not IsAddOnLoaded("GarrisonMissionManager") then
		GarrisonLandingPageMinimapButton:RegisterForClicks("AnyUp")
		GarrisonLandingPageMinimapButton:HookScript("OnClick", function(_, btn, down)
			if btn == "MiddleButton" and not down then
				HideUIPanel(GarrisonLandingPage)
				ShowGarrisonLandingPage(LE_GARRISON_TYPE_7_0)
			elseif btn == "RightButton" and not down then
				HideUIPanel(GarrisonLandingPage)
				ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
			end
		end)
	end

	-- QueueStatus Button
	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -5, -5)
	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusMinimapButtonIconTexture:SetTexture(nil)

	local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
	queueIcon:SetPoint("CENTER", QueueStatusMinimapButton)
	queueIcon:SetSize(50, 50)
	queueIcon:SetTexture(DB.eyeTex)
	local anim = queueIcon:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	anim.rota = anim:CreateAnimation("Rotation")
	anim.rota:SetDuration(2)
	anim.rota:SetDegrees(360)
	hooksecurefunc("QueueStatusFrame_Update", function()
		queueIcon:SetShown(QueueStatusMinimapButton:IsShown())
	end)
	hooksecurefunc("EyeTemplate_StartAnimating", function() anim:Play() end)
	hooksecurefunc("EyeTemplate_StopAnimating", function() anim:Stop() end)

	-- Difficulty Flags
	local flags = {"MiniMapInstanceDifficulty", "GuildInstanceDifficulty", "MiniMapChallengeMode"}
	for _, v in pairs(flags) do
		local flag = _G[v]
		flag:ClearAllPoints()
		flag:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
		flag:SetScale(.9)
	end

	-- Mail icon
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
	MiniMapMailIcon:SetTexture(DB.mailTex)
	MiniMapMailIcon:SetSize(21, 21)
	MiniMapMailIcon:SetVertexColor(1, 1, 0)

	-- Invites Icon
	GameTimeCalendarInvitesTexture:ClearAllPoints()
	GameTimeCalendarInvitesTexture:SetParent("Minimap")
	GameTimeCalendarInvitesTexture:SetPoint("TOPRIGHT")

	local Invt = CreateFrame("Button", nil, UIParent)
	Invt:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -20, -20)
	Invt:SetSize(250, 80)
	Invt:Hide()
	B.SetBD(Invt)
	B.CreateFS(Invt, 16, DB.InfoColor..GAMETIME_TOOLTIP_CALENDAR_INVITES)

	local function updateInviteVisibility()
		Invt:SetShown(C_Calendar.GetNumPendingInvites() > 0)
	end
	B:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
	B:RegisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)

	Invt:SetScript("OnClick", function(_, btn)
		Invt:Hide()
		if btn == "LeftButton" and not InCombatLockdown() then
			ToggleCalendar()
		end
		B:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
		B:UnregisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)
	end)
end

function module:RecycleBin()
	if not NDuiDB["Map"]["ShowRecycleBin"] then return end

	local buttons = {}
	local blackList = {
		["GameTimeFrame"] = true,
		["MiniMapLFGFrame"] = true,
		["BattlefieldMinimap"] = true,
		["MinimapBackdrop"] = true,
		["TimeManagerClockButton"] = true,
		["FeedbackUIButton"] = true,
		["HelpOpenTicketButton"] = true,
		["MiniMapBattlefieldFrame"] = true,
		["QueueStatusMinimapButton"] = true,
		["GarrisonLandingPageMinimapButton"] = true,
		["MinimapZoneTextButton"] = true,
		["RecycleBinFrame"] = true,
		["RecycleBinToggleButton"] = true,
	}

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetSize(30, 30)
	bu:SetPoint("BOTTOMRIGHT", 4, -6)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(DB.binTex)
	bu:SetHighlightTexture(DB.binTex)
	B.AddTooltip(bu, "ANCHOR_LEFT", L["Minimap RecycleBin"], "white")

	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 10)
	bin:Hide()
	B.CreateGF(bin, 220, 40, "Horizontal", 0, 0, 0, 0, .7)
	local topLine = CreateFrame("Frame", nil, bin)
	topLine:SetPoint("BOTTOMRIGHT", bin, "TOPRIGHT", 1, 0)
	B.CreateGF(topLine, 220, 1, "Horizontal", cr, cg, cb, 0, .7)
	local bottomLine = CreateFrame("Frame", nil, bin)
	bottomLine:SetPoint("TOPRIGHT", bin, "BOTTOMRIGHT", 1, 0)
	B.CreateGF(bottomLine, 220, 1, "Horizontal", cr, cg, cb, 0, .7)
	local rightLine = CreateFrame("Frame", nil, bin)
	rightLine:SetPoint("LEFT", bin, "RIGHT", 0, 0)
	B.CreateGF(rightLine, 1, 40, "Vertical", cr, cg, cb, .7, .7)
	bin:SetFrameStrata("TOOLTIP")

	local function hideBinButton()
		bin:Hide()
	end
	local function clickFunc()
		UIFrameFadeOut(bin, .5, 1, 0)
		C_Timer.After(.5, hideBinButton)
	end

	local secureAddons = {
		["HANDYNOTESPIN"] = true,
		["GATHERMATEPIN"] = true,
	}

	local function isButtonSecure(name)
		name = strupper(name)
		for addonName in pairs(secureAddons) do
			if strmatch(name, addonName) then
				return true
			end
		end
	end

	local isCollecting

	local function CollectRubbish()
		if isCollecting then return end
		isCollecting = true

		for _, child in ipairs({Minimap:GetChildren()}) do
			local name = child:GetName()
			if name and not blackList[name] and not isButtonSecure(name) then
				if child:GetObjectType() == "Button" or strmatch(strupper(name), "BUTTON") then
					child:SetParent(bin)
					child:SetSize(34, 34)
					for j = 1, child:GetNumRegions() do
						local region = select(j, child:GetRegions())
						if region:GetObjectType() == "Texture" then
							local texture = region:GetTexture() or ""
							if strfind(texture, "Interface\\CharacterFrame") or strfind(texture, "Interface\\Minimap") then
								region:SetTexture(nil)
							elseif texture == 136430 or texture == 136467 then
								region:SetTexture(nil)
							end
							region:ClearAllPoints()
							region:SetAllPoints()
							region:SetTexCoord(unpack(DB.TexCoord))
						end
					end

					if child:HasScript("OnDragStart") then child:SetScript("OnDragStart", nil) end
					if child:HasScript("OnDragStop") then child:SetScript("OnDragStop", nil) end
					if child:HasScript("OnClick") then child:HookScript("OnClick", clickFunc) end

					if child:GetObjectType() == "Button" then
						child:SetHighlightTexture(DB.bdTex) -- prevent nil function
						child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
					elseif child:GetObjectType() == "Frame" then
						child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
						child.highlight:SetAllPoints()
						child.highlight:SetColorTexture(1, 1, 1, .25)
					end
					B.SetBD(child)

					-- Naughty Addons
					if name == "DBMMinimapButton" then
						child:SetScript("OnMouseDown", nil)
						child:SetScript("OnMouseUp", nil)
					elseif name == "BagSync_MinimapButton" then
						child:HookScript("OnMouseUp", clickFunc)
					end

					tinsert(buttons, child)
				end
			end
		end

		isCollecting = nil
	end

	local function SortRubbish()
		if #buttons == 0 then return end
		local lastbutton
		for _, button in pairs(buttons) do
			if button:IsShown() then
				button:ClearAllPoints()
				if not lastbutton then
					button:SetPoint("RIGHT", bin, -3, 0)
				else
					button:SetPoint("RIGHT", lastbutton, "LEFT", -3, 0)
				end
				lastbutton = button
			end
		end
	end

	bu:SetScript("OnClick", function()
		SortRubbish()
		if bin:IsShown() then
			clickFunc()
		else
			UIFrameFadeIn(bin, .5, 0, 1)
		end
	end)

	C_Timer.After(.3, function()
		CollectRubbish()
		SortRubbish()
	end)
end

function module:WhoPingsMyMap()
	if not NDuiDB["Map"]["WhoPings"] then return end

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetAllPoints()
	f.text = B.CreateFS(f, 12, "", false, "TOP", 0, -3)

	local anim = f:CreateAnimationGroup()
	anim:SetScript("OnPlay", function() f:SetAlpha(1) end)
	anim:SetScript("OnFinished", function() f:SetAlpha(0) end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(3)

	B:RegisterEvent("MINIMAP_PING", function(_, unit)
		local class = select(2, UnitClass(unit))
		local r, g, b = B.ClassColor(class)
		local name = GetUnitName(unit)

		anim:Stop()
		f.text:SetText(name)
		f.text:SetTextColor(r, g, b)
		anim:Play()
	end)
end

function module:UpdateMinimapScale()
	local size = Minimap:GetWidth()
	local scale = NDuiDB["Map"]["MinimapScale"]
	Minimap:SetScale(scale)
	Minimap.mover:SetSize(size*scale, size*scale)
	-- Other elements
	if _G.NDuiMinimapDataBar then
		_G.NDuiMinimapDataBar:SetWidth((size-10)*scale)
	end
end

function module:ShowMinimapClock()
	if NDuiDB["Map"]["Clock"] then
		if not TimeManagerClockButton then LoadAddOn("Blizzard_TimeManager") end
		if not TimeManagerClockButton.styled then
			TimeManagerClockButton:DisableDrawLayer("BORDER")
			TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -8)
			TimeManagerClockTicker:SetFont(unpack(DB.Font))
			TimeManagerClockTicker:SetTextColor(1, 1, 1)

			TimeManagerClockButton.styled = true
		end
		TimeManagerClockButton:Show()
	else
		if TimeManagerClockButton then TimeManagerClockButton:Hide() end
	end
end

function module:ShowCalendar()
	if NDuiDB["Map"]["Calendar"] then
		if not GameTimeFrame.styled then
			GameTimeFrame:SetNormalTexture(nil)
			GameTimeFrame:SetPushedTexture(nil)
			GameTimeFrame:SetHighlightTexture(nil)
			GameTimeFrame:SetSize(18, 18)
			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("BOTTOMRIGHT", Minimap, 1, 18)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)

			for i = 1, GameTimeFrame:GetNumRegions() do
				local region = select(i, GameTimeFrame:GetRegions())
				if region.SetTextColor then
					region:SetTextColor(cr, cg, cb)
					region:SetFont(unpack(DB.Font))
					break
				end
			end

			GameTimeFrame.styled = true
		end
		GameTimeFrame:Show()
	else
		GameTimeFrame:Hide()
	end
end

function module:SetupMinimap()
	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	DropDownList1:SetClampedToScreen(true)

	local mover = B.Mover(Minimap, L["Minimap"], "Minimap", C.Minimap.Pos)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", mover)
	Minimap.mover = mover

	self:UpdateMinimapScale()
	self:ShowMinimapClock()
	self:ShowCalendar()

	-- Mousewheel Zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, zoom)
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)

	-- Click Func
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "MiddleButton" then
			if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
			ToggleCalendar()
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, -(self:GetWidth()*.7), (self:GetWidth()*.3))
		else
			Minimap_OnClick(self)
		end
	end)

	-- Hide Blizz
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MiniMapTracking",
	}

	for _, v in pairs(frames) do
		B.HideObject(_G[v])
	end
	MinimapCluster:EnableMouse(false)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	-- Add Elements
	self:CreatePulse()
	self:ReskinRegions()
	self:RecycleBin()
	self:WhoPingsMyMap()
end