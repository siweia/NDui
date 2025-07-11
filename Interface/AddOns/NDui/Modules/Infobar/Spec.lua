local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Spec then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Spec", C.Infobar.SpecPos)
if DB.isMop then

local GetTalentInfo = C_SpecializationInfo.GetTalentInfo
local GetSpecialization = C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo
local SetSpecialization = C_SpecializationInfo.SetSpecialization

local function addIcon(texture)
	texture = texture and "|T"..texture..":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local currentSpecIndex, currentLootIndex, newMenu, numSpecs, numLocal

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
}

info.onEvent = function(self)
	currentSpecIndex = GetSpecialization()
	if currentSpecIndex and currentSpecIndex < 5 then
		local _, name, _, icon = GetSpecializationInfo(currentSpecIndex)
		if not name then return end
		currentLootIndex = GetLootSpecialization()
		if currentLootIndex == 0 then
			icon = addIcon(icon)
		else
			icon = addIcon(select(4, GetSpecializationInfoByID(currentLootIndex)))
		end
		self.text:SetText(DB.MyColor..name..icon)
	else
		self.text:SetText(SPECIALIZATION..": "..DB.MyColor..NONE)
	end
end

info.onEnter = function(self)
	if not currentSpecIndex or currentSpecIndex == 5 then return end

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0,.6,1)
	GameTooltip:AddLine(" ")

	local specID, specName, _, specIcon = GetSpecializationInfo(currentSpecIndex)
	GameTooltip:AddLine(addIcon(specIcon).." "..specName, .6,.8,1)
--[[]
	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(addIcon(icon).." "..name, 1,1,1)
			end
		end
	end
]]

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1,1,1, .6,.8,1)
	--GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Change Spec"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

local function selectSpec(_, specIndex)
	if currentSpecIndex == specIndex then return end
	SetSpecialization(specIndex)
	DropDownList1:Hide()
end

local function checkSpec(self)
	return currentSpecIndex == self.arg1
end

local function selectLootSpec(_, index)
	SetLootSpecialization(index)
	DropDownList1:Hide()
end

local function checkLootSpec(self)
	return currentLootIndex == self.arg1
end

local function refreshDefaultLootSpec()
	if not currentSpecIndex or currentSpecIndex == 5 then return end
	local mult = 3 + numSpecs
	newMenu[numLocal - mult].text = format(LOOT_SPECIALIZATION_DEFAULT, (select(2, GetSpecializationInfo(currentSpecIndex))) or NONE)
end

local seperatorMenu = {
	text = "",
	isTitle = true,
	notCheckable = true,
	iconOnly = true,
	icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
	iconInfo = {
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = 0,
		tCoordBottom = 1,
		tSizeX = 0,
		tSizeY = 8,
		tFitDropDownSizeX = true
	},
}

local function BuildSpecMenu()
	if newMenu then return end

	newMenu = {
		{text = SPECIALIZATION, isTitle = true, notCheckable = true},
		seperatorMenu,
		{text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
		{text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec},
	}

	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			numSpecs = (numSpecs or 0) + 1
			tinsert(newMenu, i+1, {text = name, arg1 = i, func = selectSpec, checked = checkSpec})
			tinsert(newMenu, {text = name, arg1 = id, func = selectLootSpec, checked = checkLootSpec})
		end
	end

	numLocal = #newMenu

	refreshDefaultLootSpec()
	B:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshDefaultLootSpec)
end

info.onMouseUp = function(self, btn)
	if not currentSpecIndex or currentSpecIndex == 5 then return end

	if btn == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame()
	else
	--	BuildSpecMenu()
	--	EasyMenu(newMenu, B.EasyMenu, self, -80, 100, "MENU", 1)
	--	GameTooltip:Hide()
	end
end

	return
end

local format = string.format
local TALENT, SHOW_SPEC_LEVEL, FEATURE_BECOMES_AVAILABLE_AT_LEVEL, NONE = TALENT, SHOW_SPEC_LEVEL, FEATURE_BECOMES_AVAILABLE_AT_LEVEL, NONE
local ToggleTalentFrame, UnitCharacterPoints = ToggleTalentFrame, UnitCharacterPoints
local talentString = "%s (%s)"
local unspendPoints = gsub(CHARACTER_POINTS1_COLON, HEADER_COLON, "")

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"CHARACTER_POINTS_CHANGED",
	"SPELLS_CHANGED",
}

info.onEvent = function(self)
	local text = ""
	local higher = 0
	for i = 1, 5 do
		local _, nameCata, _, _, pointsSpentCata = GetTalentTabInfo(i)
		if not nameCata then break end
		if pointsSpentCata > higher then
			higher = pointsSpentCata
			text = nameCata
		end
	end
	if text == "" then
		text = NONE
	end
	local points = UnitCharacterPoints("player")
	if points > 0 then
		text = format(talentString, text, points)
	end
	self.text:SetText(TALENT..": "..DB.MyColor..text)
end

info.onEnter = function(self)
	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENT, 0,.6,1)
	GameTooltip:AddLine(" ")

	for i = 1, 5 do
		local _, nameCata, _, _, pointsSpentCata = GetTalentTabInfo(i)
		if not nameCata then break end
		GameTooltip:AddDoubleLine(nameCata, pointsSpentCata, 1,1,1, 1,.8,0)
	end
	local points = UnitCharacterPoints("player")
	if points > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(unspendPoints, points, .6,.8,1, 1,.8,0)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1,1,1, .6,.8,1)
	if GetNumTalentGroups() > 1 then
		GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Change Spec"].." ", 1,1,1, .6,.8,1)
	end
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

info.onMouseUp = function(_, btn)
	if UnitLevel("player") < SHOW_SPEC_LEVEL then
		UIErrorsFrame:AddMessage(DB.InfoColor..format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL))
	elseif btn == "RightButton" then
		if InCombatLockdown() then return end
		if GetNumTalentGroups() < 2 then return end
		local idx = GetActiveTalentGroup()
		SetActiveTalentGroup(idx == 1 and 2 or 1)
	else
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame()
	end
end