local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Spec then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Spec", C.Infobar.SpecPos)

local GetSpecialization = C_SpecializationInfo.GetSpecialization
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo
local SetSpecialization = C_SpecializationInfo.SetSpecialization or SetSpecialization

local function addIcon(texture)
	texture = texture and "|T"..texture..":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local currentSpecIndex, currentLootIndex, newMenu, numSpecs, numLocal

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED"
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

	for i = 1, 2 do
		local specID, specName, _, specIcon = GetSpecializationInfo(i)
		GameTooltip:AddLine(addIcon(specIcon).." "..specName, .6,.8,1)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Change Spec"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = B.HideTooltip

local function selectSpec(_, specIndex)
	if GetActiveTalentGroup() == specIndex then return end
	SetActiveTalentGroup(specIndex)
	DropDownList1:Hide()
end

local function checkSpec(self)
	return GetActiveTalentGroup() == self.arg1
end

local function updateLootSpec()
	info:onEvent()
end

local function selectLootSpec(_, index)
	SetLootSpecialization(index)
	DropDownList1:Hide()
	C_Timer.After(1, updateLootSpec) -- no event fired after SetLootSpecialization
end

local function checkLootSpec(self)
	return currentLootIndex == self.arg1
end

local function refreshDefaultLootSpec()
	if not currentSpecIndex or currentSpecIndex == 5 then return end
	newMenu[numLocal].text = format(" "..LOOT_SPECIALIZATION_DEFAULT, (select(2, GetSpecializationInfo(currentSpecIndex))) or NONE)
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
		{text = " "..SPECIALIZATION, isTitle = true, notCheckable = true},
		{text = " "..SPECIALIZATION_PRIMARY, arg1 = 1, func = selectSpec, checked = checkSpec},
		{text = " "..SPECIALIZATION_SECONDARY, arg1 = 2, func = selectSpec, checked = checkSpec},
		seperatorMenu,
		{text = " "..SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
		{text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec},
	}
	numLocal = #newMenu

	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id and id ~= 0 then
			numSpecs = (numSpecs or 0) + 1
			tinsert(newMenu, {text = " "..name, arg1 = id, func = selectLootSpec, checked = checkLootSpec})
		end
	end

	refreshDefaultLootSpec()
	B:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshDefaultLootSpec)
end

info.onMouseUp = function(self, btn)
	if not currentSpecIndex or currentSpecIndex == 5 then return end

	if btn == "LeftButton" then
		if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame()
	else
		BuildSpecMenu()
		EasyMenu(newMenu, B.EasyMenu, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end