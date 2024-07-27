local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Spec then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Spec", C.Infobar.SpecPos)
local format, wipe, select, next = string.format, table.wipe, select, next
local SPECIALIZATION, TALENTS_BUTTON, MAX_TALENT_TIERS = SPECIALIZATION, TALENTS_BUTTON, MAX_TALENT_TIERS
local PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT = PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT
local GetSpecialization, GetSpecializationInfo, GetLootSpecialization, GetSpecializationInfoByID = GetSpecialization, GetSpecializationInfo, GetLootSpecialization, GetSpecializationInfoByID
local GetTalentInfo, GetPvpTalentInfoByID, SetLootSpecialization, SetSpecialization = GetTalentInfo, GetPvpTalentInfoByID, SetLootSpecialization, SetSpecialization
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_SpecializationInfo_CanPlayerUsePVPTalentUI = C_SpecializationInfo.CanPlayerUsePVPTalentUI
local STARTER_BUILD = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local function addIcon(texture)
	texture = texture and "|T"..texture..":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local currentSpecIndex, currentLootIndex, newMenu, numSpecs, numLocal

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED",
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

local pvpTalents
local pvpIconTexture = C_CurrencyInfo.GetCurrencyInfo(104).iconFileID

info.onEnter = function(self)
	if not currentSpecIndex or currentSpecIndex == 5 then return end

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0,.6,1)
	GameTooltip:AddLine(" ")

	local specID, specName, _, specIcon = GetSpecializationInfo(currentSpecIndex)
	GameTooltip:AddLine(addIcon(specIcon).." "..specName, .6,.8,1)

	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(addIcon(icon).." "..name, 1,1,1)
			end
		end
	end

	local configID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
	local info = configID and C_Traits.GetConfigInfo(configID)
	if info and info.name then
		GameTooltip:AddLine("   ("..info.name..")", 1,1,1)
	end

	if C_SpecializationInfo_CanPlayerUsePVPTalentUI() then
		pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()

		if #pvpTalents > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(addIcon(pvpIconTexture).." "..PVP_TALENTS, .6,.8,1)
			for _, talentID in next, pvpTalents do
				local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
				if name and unlocked then
					GameTooltip:AddLine(addIcon(icon).." "..name, 1,1,1)
				end
			end
		end

		wipe(pvpTalents)
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Change Spec"].." ", 1,1,1, .6,.8,1)
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

local function selectCurrentConfig(_, configID, specID)
	if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end
	if configID == STARTER_BUILD then
		C_ClassTalents.SetStarterBuildActive(true)
	else
		C_ClassTalents.LoadConfig(configID, true)
		C_ClassTalents.SetStarterBuildActive(false)
	end
	C_ClassTalents.UpdateLastSelectedSavedConfigID(specID or GetSpecializationInfo(currentSpecIndex), configID)
end

local function checkCurrentConfig(self)
	return C_ClassTalents.GetLastSelectedSavedConfigID(self.arg2) == self.arg1
end

local function refreshAllTraits()
	local numConfig = numLocal or 0
	local specID = GetSpecializationInfo(currentSpecIndex)
	local configIDs = specID and C_ClassTalents.GetConfigIDsBySpecID(specID)
	if configIDs then
		for i = 1, #configIDs do
			local configID = configIDs[i]
			if configID then
				local info = C_Traits.GetConfigInfo(configID)
				numConfig = numConfig + 1
				if not newMenu[numConfig] then newMenu[numConfig] = {} end
				newMenu[numConfig].text = info.name
				newMenu[numConfig].arg1 = configID
				newMenu[numConfig].arg2 = specID
				newMenu[numConfig].func = selectCurrentConfig
				newMenu[numConfig].checked = checkCurrentConfig
			end
		end
	end

	for i = numConfig+1, #newMenu do
		if newMenu[i] then newMenu[i].text = nil end
	end
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

	tinsert(newMenu, seperatorMenu)
	tinsert(newMenu, {text = C_Spell.GetSpellName(384255), isTitle = true, notCheckable = true})
	tinsert(newMenu, {text = BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD), func = selectCurrentConfig,
		arg1 = STARTER_BUILD,	checked = function() return C_ClassTalents.GetStarterBuildActive() end,
	})

	numLocal = #newMenu

	refreshDefaultLootSpec()
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", refreshDefaultLootSpec)

	refreshAllTraits()
	B:RegisterEvent("TRAIT_CONFIG_DELETED", refreshAllTraits)
	B:RegisterEvent("TRAIT_CONFIG_UPDATED", refreshAllTraits)
	B:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", refreshAllTraits)
end

info.onMouseUp = function(self, btn)
	if not currentSpecIndex or currentSpecIndex == 5 then return end

	if btn == "LeftButton" then
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
	else
		BuildSpecMenu()
		EasyMenu(newMenu, B.EasyMenu, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end