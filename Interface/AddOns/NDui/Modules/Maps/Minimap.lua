local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("Minimap")

function module:CreatePulse()
	if not NDuiDB["Map"]["CombatPulse"] then return end

	local MBG = CreateFrame("Frame", nil, Minimap)
	MBG:SetFrameLevel(Minimap:GetFrameLevel() - 1)
	MBG:SetPoint("TOPLEFT", -3, 3)
	MBG:SetPoint("BOTTOMRIGHT", 3, -3)
	B.CreateBD(MBG)
	local anim = MBG:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(.8)
	anim.fader:SetToAlpha(.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	local f = NDui:EventFrame{"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "CALENDAR_UPDATE_PENDING_INVITES", "UPDATE_PENDING_MAIL"}
	f:SetScript("OnEvent", function(_, event)
		if event == "PLAYER_REGEN_DISABLED" then
			MBG:SetBackdropBorderColor(1, 0, 0)
			anim:Play()
		elseif not InCombatLockdown() then
			if CalendarGetNumPendingInvites() > 0 or MiniMapMailFrame:IsShown() then
				MBG:SetBackdropBorderColor(1, 1, 0)
				anim:Play()
			else
				anim:Stop()
				MBG:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end)
	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then return end
		anim:Stop()
		MBG:SetBackdropBorderColor(0, 0, 0)
	end)
end

function module:ReskinRegions()
	-- Garrison
	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, 6, -6)
	GarrisonLandingPageMinimapButton:SetScale(.55)
	hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(bu)
		bu:GetNormalTexture():SetTexture(DB.garrTex)
		bu:GetPushedTexture():SetTexture(DB.garrTex)
	end)

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
		flag:SetScale(.75)
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
	local Invt = CreateFrame("Button", "NDuiInvt", UIParent)
	Invt:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -20, -20)
	Invt:SetSize(300, 80)
	B.CreateBD(Invt)
	B.CreateTex(Invt)
	B.CreateFS(Invt, 16, DB.InfoColor..GAMETIME_TOOLTIP_CALENDAR_INVITES)

	local f = NDui:EventFrame{"CALENDAR_UPDATE_PENDING_INVITES", "PLAYER_ENTERING_WORLD"}
	f:SetScript("OnEvent", function()
		if NDuiDB["Map"]["Invite"] and CalendarGetNumPendingInvites() > 0 then
			Invt:Show()
		else
			Invt:Hide()
		end
	end)
	Invt:SetScript("OnClick", function(_, btn)
		Invt:UnregisterAllEvents()
		Invt:Hide()
		if btn == "LeftButton" then ToggleCalendar() end
	end)

	-- Micro Button Alerts
	if TalentMicroButtonAlert then
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -220, 40)
		TalentMicroButtonAlert:SetScript("OnMouseUp", function()
			if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
			ToggleFrame(PlayerTalentFrame)
		end)
	end

	if EJMicroButtonAlert then
		EJMicroButtonAlert:ClearAllPoints()
		EJMicroButtonAlert:SetPoint("BOTTOM", UIParent, "BOTTOM", 40, 40)
		EJMicroButtonAlert:SetScript("OnMouseUp", function()
			if not EncounterJournal then LoadAddOn("Blizzard_EncounterJournal") end
			ToggleFrame(EncounterJournal)
		end)
	end

	if CollectionsMicroButtonAlert then
		CollectionsMicroButtonAlert:ClearAllPoints()
		CollectionsMicroButtonAlert:SetPoint("BOTTOM", UIParent, "BOTTOM", 65, 40)
		CollectionsMicroButtonAlert:SetScript("OnMouseUp", function()
			if not CollectionsJournal then LoadAddOn("Blizzard_Collections") end
			ToggleFrame(CollectionsJournal)
			CollectionsJournal_SetTab(CollectionsJournal, 2)
		end)
	end

	if TicketStatusFrame then
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint("TOP", UIParent, "TOP", -400, -20)
		TicketStatusFrame.SetPoint = B.Dummy
	end
end

function module:RecycleBin()
	if not NDuiDB["Map"]["ShowRecycleBin"] then return end
	local r, g, b = DB.cc.r, DB.cc.g, DB.cc.b

	local buttons = {}
	local blackList = {
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
	bu:SetSize(24, 24)
	bu:SetPoint("BOTTOMLEFT", -15, -15)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(DB.binTex)
	bu:SetHighlightTexture(DB.binTex)
	B.CreateGT(bu, "ANCHOR_LEFT", L["Minimap RecycleBin"], "white")

	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("RIGHT", bu, "LEFT", -3, -6)
	bin:Hide()
	B.CreateGF(bin, 220, 40, "Horizontal", 0, 0, 0, 0, .7)
	local topLine = CreateFrame("Frame", nil, bin)
	topLine:SetPoint("BOTTOMRIGHT", bin, "TOPRIGHT", 1, 0)
	B.CreateGF(topLine, 220, 1, "Horizontal", r, g, b, 0, .7)
	local bottomLine = CreateFrame("Frame", nil, bin)
	bottomLine:SetPoint("TOPRIGHT", bin, "BOTTOMRIGHT", 1, 0)
	B.CreateGF(bottomLine, 220, 1, "Horizontal", r, g, b, 0, .7)
	local rightLine = CreateFrame("Frame", nil, bin)
	rightLine:SetPoint("LEFT", bin, "RIGHT", 0, 0)
	B.CreateGF(rightLine, 1, 40, "Vertical", r, g, b, .7, .7)
	bin:SetFrameStrata("LOW")

	local function clickFunc()
		UIFrameFadeOut(bin, .5, 1, 0)
		C_Timer.After(.5, function() bin:Hide() end)
	end

	local function CollectRubbish()
		for _, child in ipairs({Minimap:GetChildren()}) do
			local name = child:GetName()
			if name and not blackList[name] and not strupper(name):match("HANDYNOTES") then
				if child:GetObjectType() == "Button" or strupper(name):match("BUTTON") then
					child:SetParent(bin)
					child:SetSize(34, 34)
					for j = 1, child:GetNumRegions() do
						local region = select(j, child:GetRegions())
						if region:GetObjectType() == "Texture" then
							local texture = region:GetTexture()
							if (string.find(texture, "Interface\\CharacterFrame") or string.find(texture, "Interface\\Minimap")) then
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
						child:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
					elseif child:GetObjectType() == "Frame" then
						child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
						child.highlight:SetAllPoints()
						child.highlight:SetColorTexture(1, 1, 1, .3)
					end
					B.CreateSD(child, 3, 3)

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

	NDui:EventFrame{"MINIMAP_PING"}:SetScript("OnEvent", function(_, _, unit)
		local class = select(2, UnitClass(unit))
		local r, g, b = B.ClassColor(class)
		local name = GetUnitName(unit)

		anim:Stop()
		f.text:SetText(name)
		f.text:SetTextColor(r, g, b)
		anim:Play()
	end)
end

function module:OnLogin()
	-- Shape and Position
	local scale = NDuiDB["Map"]["MinmapScale"]
	function GetMinimapShape() return "SQUARE" end
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8X8")
	MinimapCluster:SetScale(scale)
	DropDownList1:SetClampedToScreen(true)

	local mover = B.Mover(Minimap, L["Minimap"], "Minimap", C.Minimap.Pos, Minimap:GetWidth()*scale, Minimap:GetHeight()*scale)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", mover)

	-- ClockFrame
	if NDuiDB["Map"]["Clock"] then
		if not TimeManagerClockButton then LoadAddOn("Blizzard_TimeManager") end
		local clockFrame, clockTime = TimeManagerClockButton:GetRegions()
		clockFrame:Hide()
		clockTime:SetFont(unpack(DB.Font))
		clockTime:SetTextColor(1, 1, 1)
		TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -6)
	else
		if TimeManagerClockButton then TimeManagerClockButton:Hide() end
		GameTimeFrame:Hide()
	end

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
			ToggleCalendar()
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, -(self:GetWidth()*.7), (self:GetWidth()*.3))
		else
			Minimap_OnClick(self)
		end
	end)

	-- Hide Blizz
	local frames = {
		"GameTimeFrame",
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapVoiceChatFrame",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MiniMapTracking",
	}

	for _, v in pairs(frames) do
		_G[v]:Hide()
		_G[v].Show = B.Dummy
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