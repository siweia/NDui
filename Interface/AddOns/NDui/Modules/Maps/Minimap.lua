local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Maps")

local select, pairs, unpack, next, tinsert = select, pairs, unpack, next, tinsert
local strmatch, strfind, strupper = strmatch, strfind, strupper
local UIFrameFadeOut, UIFrameFadeIn = UIFrameFadeOut, UIFrameFadeIn
local GetInstanceInfo, GetDifficultyInfo = GetInstanceInfo, GetDifficultyInfo
local C_Timer_After = C_Timer.After
local cr, cg, cb = DB.r, DB.g, DB.b

function module:CreatePulse()
	if not C.db["Map"]["CombatPulse"] then return end

	local bg = B.SetBD(Minimap)
	bg:SetFrameStrata("BACKGROUND")
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
			if MiniMapMailFrame:IsShown() then
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
	B:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapAnim)

	MiniMapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then return end
		anim:Stop()
		bg:SetBackdropBorderColor(0, 0, 0)
	end)
end

function module:ReskinRegions()
	-- Tracking icon
	MiniMapTracking:SetScale(.7)
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("BOTTOMRIGHT", Minimap, -2, 0)
	MiniMapTrackingBorder:Hide()
	MiniMapTrackingBackground:Hide()
	B.ReskinIcon(MiniMapTrackingIcon)

	MiniMapTracking:SetHighlightTexture(DB.bdTex)
	local hl = MiniMapTracking:GetHighlightTexture()
	hl:SetVertexColor(1, 1, 1, .25)
	hl:SetAllPoints(MiniMapTrackingIcon)

	-- Mail icon
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -3, 3)
	MiniMapMailIcon:SetTexture(DB.mailTex)
	MiniMapMailIcon:SetSize(21, 21)
	MiniMapMailIcon:SetVertexColor(1, 1, 0)

	-- Battlefield
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -5, -5)
	MiniMapBattlefieldBorder:Hide()
	MiniMapBattlefieldIcon:SetAlpha(0)
	BattlegroundShine:SetTexture(nil)

	local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
	queueIcon:SetPoint("CENTER", MiniMapBattlefieldFrame)
	queueIcon:SetSize(50, 50)
	queueIcon:SetTexture(DB.eyeTex)
	queueIcon:Hide()
	local anim = queueIcon:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	anim.rota = anim:CreateAnimation("Rotation")
	anim.rota:SetDuration(2)
	anim.rota:SetDegrees(360)

	hooksecurefunc("BattlefieldFrame_UpdateStatus", function()
		queueIcon:SetShown(MiniMapBattlefieldFrame:IsShown())

		anim:Play()
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				anim:Stop()
				break
			end
		end
	end)

	-- LFG Icon
	if MiniMapLFGFrame then
		MiniMapLFGFrame:ClearAllPoints()
		MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, 5, 15)
		MiniMapLFGBorder:Hide()
	end
end

function module:RecycleBin()
	if not C.db["Map"]["ShowRecycleBin"] then return end

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

	local function updateRecycleTip(bu)
		bu.text = DB.RightButton..L["AutoHide"]..": "..(NDuiADB["AutoRecycle"] and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED)
	end

	local bu = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
	bu:SetSize(30, 30)
	bu:SetPoint("BOTTOMRIGHT", -15, -6)
	bu:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(DB.binTex)
	bu:SetHighlightTexture(DB.binTex)
	bu.title = DB.InfoColor..L["Minimap RecycleBin"]
	B.AddTooltip(bu, "ANCHOR_LEFT")
	updateRecycleTip(bu)

	local width, height, alpha = 220, 40, .5
	local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
	bin:SetPoint("BOTTOMRIGHT", bu, "BOTTOMLEFT", -3, 10)
	bin:SetSize(width, height)
	bin:Hide()

	local tex = B.SetGradient(bin, "H", 0, 0, 0, 0, alpha, width, height)
	tex:SetPoint("CENTER")
	local topLine = B.SetGradient(bin, "H", cr, cg, cb, 0, alpha, width, C.mult)
	topLine:SetPoint("BOTTOM", bin, "TOP")
	local bottomLine = B.SetGradient(bin, "H", cr, cg, cb, 0, alpha, width, C.mult)
	bottomLine:SetPoint("TOP", bin, "BOTTOM")
	local rightLine = B.SetGradient(bin, "V", cr, cg, cb, alpha, alpha, C.mult, height + C.mult*2)
	rightLine:SetPoint("LEFT", bin, "RIGHT")

	local function hideBinButton()
		bin:Hide()
	end
	local function clickFunc(force)
		if force == 1 or NDuiADB["AutoRecycle"] then
			UIFrameFadeOut(bin, .5, 1, 0)
			C_Timer_After(.5, hideBinButton)
		end
	end

	local ignoredButtons = {
		["GatherMatePin"] = true,
		["HandyNotes.-Pin"] = true,
		["Guidelime"] = true,
		["QuestieFrame"] = true,
	}
	B.SplitList(ignoredButtons, NDuiADB["IgnoredButtons"])

	local function isButtonIgnored(name)
		for addonName in pairs(ignoredButtons) do
			if strmatch(name, addonName) then
				return true
			end
		end
	end

	local isGoodLookingIcon = {}

	local iconsPerRow = 10
	local rowMult = iconsPerRow/2 - 1
	local currentIndex, pendingTime, timeThreshold = 0, 5, 12
	local buttons, numMinimapChildren = {}, 0
	local removedTextures = {
		[136430] = true,
		[136467] = true,
	}

	local function ReskinMinimapButton(child, name)
		for j = 1, child:GetNumRegions() do
			local region = select(j, child:GetRegions())
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture() or ""
				if removedTextures[texture] or strfind(texture, "Interface\\CharacterFrame") or strfind(texture, "Interface\\Minimap") then
					region:SetTexture(nil)
				end
				region:ClearAllPoints()
				region:SetAllPoints()
				if not isGoodLookingIcon[name] then
					region:SetTexCoord(unpack(DB.TexCoord))
				end
			end
			child:SetSize(34, 34)
			B.CreateSD(child, 3, 3)
		end

		tinsert(buttons, child)
	end

	local function KillMinimapButtons()
		for _, child in pairs(buttons) do
			if not child.styled then
				child:SetParent(bin)
				if child:HasScript("OnDragStop") then child:SetScript("OnDragStop", nil) end
				if child:HasScript("OnDragStart") then child:SetScript("OnDragStart", nil) end
				if child:HasScript("OnClick") then child:HookScript("OnClick", clickFunc) end

				if child:IsObjectType("Button") then
					child:SetHighlightTexture(DB.bdTex) -- prevent nil function
					child:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
				elseif child:IsObjectType("Frame") then
					child.highlight = child:CreateTexture(nil, "HIGHLIGHT")
					child.highlight:SetAllPoints()
					child.highlight:SetColorTexture(1, 1, 1, .25)
				end

				-- Naughty Addons
				local name = child:GetName()
				if name == "DBMMinimapButton" then
					child:SetScript("OnMouseDown", nil)
					child:SetScript("OnMouseUp", nil)
				elseif name == "BagSync_MinimapButton" then
					child:HookScript("OnMouseUp", clickFunc)
				end

				child.styled = true
			end
		end
	end

	local function CollectRubbish()
		local numChildren = Minimap:GetNumChildren()
		if numChildren ~= numMinimapChildren then
			for i = 1, numChildren do
				local child = select(i, Minimap:GetChildren())
				local name = child and child.GetName and child:GetName()
				if name and not child.isExamed and not blackList[name] then
					if (child:IsObjectType("Button") or strmatch(strupper(name), "BUTTON")) and not isButtonIgnored(name) then
						ReskinMinimapButton(child, name)
					end
					child.isExamed = true
				end
			end

			numMinimapChildren = numChildren
		end

		KillMinimapButtons()

		currentIndex = currentIndex + 1
		if currentIndex < timeThreshold then
			C_Timer_After(pendingTime, CollectRubbish)
		end
	end

	local shownButtons = {}
	local function SortRubbish()
		if #buttons == 0 then return end

		wipe(shownButtons)
		for _, button in pairs(buttons) do
			if next(button) and button:IsShown() then -- fix for fuxking AHDB
				tinsert(shownButtons, button)
			end
		end

		local numShown = #shownButtons
		local row = numShown == 0 and 1 or B:Round((numShown + rowMult) / iconsPerRow)
		local newHeight = row*37 + 3
		bin:SetHeight(newHeight)
		tex:SetHeight(newHeight)
		rightLine:SetHeight(newHeight + 2*C.mult)

		for index, button in pairs(shownButtons) do
			button:ClearAllPoints()
			if index == 1 then
				button:SetPoint("BOTTOMRIGHT", bin, -3, 3)
			elseif row > 1 and mod(index, row) == 1 or row == 1 then
				button:SetPoint("RIGHT", shownButtons[index - row], "LEFT", -3, 0)
			else
				button:SetPoint("BOTTOM", shownButtons[index - 1], "TOP", 0, 3)
			end
		end
	end

	bu:SetScript("OnClick", function(_, btn)
		if btn == "RightButton" then
			NDuiADB["AutoRecycle"] = not NDuiADB["AutoRecycle"]
			updateRecycleTip(bu)
			bu:GetScript("OnEnter")(bu)
		else
			if bin:IsShown() then
				clickFunc(1)
			else
				SortRubbish()
				UIFrameFadeIn(bin, .5, 0, 1)
			end
		end
	end)

	CollectRubbish()
end

function module:WhoPingsMyMap()
	if not C.db["Map"]["WhoPings"] then return end

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
		if unit == "player" then return end -- ignore player ping

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
	local size = C.db["Map"]["MinimapSize"]
	local scale = C.db["Map"]["MinimapScale"]
	Minimap:SetSize(size, size)
	Minimap:SetScale(scale)
	if Minimap.mover then
		Minimap.mover:SetSize(size*scale, size*scale)
	end
end

function GetMinimapShape() -- LibDBIcon
	if not module.initialized then
		module:UpdateMinimapScale()
		module.initialized = true
	end
	return "SQUARE"
end

function module:ShowMinimapClock()
	if C.db["Map"]["Clock"] then
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

function module:EasyTrackMenu()
	local hasAlaCalendar = IsAddOnLoaded("alaCalendar")
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "MiddleButton" and hasAlaCalendar then
			B:TogglePanel(ALA_CALENDAR)
		else
			Minimap_OnClick(self)
		end
	end)
end

function module:ShowMinimapHelpInfo()
	Minimap:HookScript("OnEnter", function()
		if not NDuiADB["Help"]["MinimapInfo"] then
			B:ShowHelpTip(MinimapCluster, L["MinimapHelp"], "LEFT", -20, -50, nil, "MinimapInfo")
		end
	end)
end

local function UpdateDifficultyFlag()
	local frame = _G["NDuiMinimapDifficulty"]
	local _, instanceType, difficulty, _, _, _, _, _, instanceGroupSize = GetInstanceInfo()
	local _, _, isHeroic, _, displayHeroic = GetDifficultyInfo(difficulty)
	if instanceType == "raid" or isHeroic or displayHeroic then
		if isHeroic or displayHeroic then
			frame.tex:SetTexCoord(0, .25, .0703125, .4296875)
		else
			frame.tex:SetTexCoord(0, .25, .5703125, .9296875)
		end
		frame.text:SetText(instanceGroupSize)
		frame:Show()
	else
		frame:Hide()
	end
end

function module:MinimapDifficulty()
	if not C.db["Map"]["DiffFlag"] then return end
	if _G.MiniMapInstanceDifficulty then return end -- hide flag if blizz makes its own

	local frame = CreateFrame("Frame", "NDuiMinimapDifficulty", Minimap)
	frame:SetSize(38, 46)
	frame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
	frame:SetScale(.6)
	frame:Hide()

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
	tex:SetPoint("CENTER")
	tex:SetSize(64, 46)
	tex:SetTexCoord(0, .25, .0703125, .4140625)
	frame.tex = tex

	frame.text = B.CreateFS(frame, 15, "", true, "CENTER", 1, -8)

	B:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateDifficultyFlag)
	B:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateDifficultyFlag)
	B:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateDifficultyFlag)
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

	-- Mousewheel Zoom
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", function(_, zoom)
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
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
		"MinimapToggleButton",
		"GameTimeFrame",
	}

	for _, v in pairs(frames) do
		B.HideObject(_G[v])
	end
	MinimapCluster:EnableMouse(false)

	-- Add Elements
	self:CreatePulse()
	self:ReskinRegions()
	self:RecycleBin()
	self:WhoPingsMyMap()
	self:EasyTrackMenu()
	self:ShowMinimapHelpInfo()
	self:MinimapDifficulty()

	if LibDBIcon10_TownsfolkTracker then
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("OVERLAY")
		LibDBIcon10_TownsfolkTracker:DisableDrawLayer("BACKGROUND")
	end
end