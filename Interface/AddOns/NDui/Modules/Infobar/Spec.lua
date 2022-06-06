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

local function addIcon(texture)
	texture = texture and "|T"..texture..":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local menuList = {
	{text = CHOOSE_SPECIALIZATION, isTitle = true, notCheckable = true},
	{text = SPECIALIZATION, hasArrow = true, notCheckable = true, menuList = {}},
	{text = SELECT_LOOT_SPECIALIZATION, hasArrow = true, notCheckable = true, menuList = {}},
}

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED",
}

info.onEvent = function(self)
	local specIndex = GetSpecialization()
	if specIndex and specIndex < 5 then
		local _, name, _, icon = GetSpecializationInfo(specIndex)
		if not name then return end
		local specID = GetLootSpecialization()
		if specID == 0 then
			icon = addIcon(icon)
		else
			icon = addIcon(select(4, GetSpecializationInfoByID(specID)))
		end
		self.text:SetText(DB.MyColor..name..icon)
	else
		self.text:SetText(SPECIALIZATION..": "..DB.MyColor..NONE)
	end
end

local pvpTalents
local pvpIconTexture = C_CurrencyInfo.GetCurrencyInfo(104).iconFileID

info.onEnter = function(self)
	local specIndex = GetSpecialization()
	if not specIndex or specIndex == 5 then return end

	local _, anchor, offset = module:GetTooltipAnchor(info)
	GameTooltip:SetOwner(self, "ANCHOR_"..anchor, 0, offset)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0,.6,1)
	GameTooltip:AddLine(" ")

	local _, specName, _, specIcon = GetSpecializationInfo(specIndex)
	GameTooltip:AddLine(addIcon(specIcon).." "..specName, .6,.8,1)

	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(addIcon(icon).." "..name, 1,1,1)
			end
		end
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
	if GetSpecialization() == specIndex then return end
	SetSpecialization(specIndex)
	DropDownList1:Hide()
end

local function checkSpec(self)
	return GetSpecialization() == self.arg1
end

local function selectLootSpec(_, index)
	SetLootSpecialization(index)
	DropDownList1:Hide()
end

local function checkLootSpec(self)
	return GetLootSpecialization() == self.arg1
end

local function BuildSpecMenu()
	local specList = menuList[2].menuList
	local lootList = menuList[3].menuList
	lootList[1] = {text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec}

	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			specList[i] = {text = name, arg1 = i, func = selectSpec, checked = checkSpec}
			lootList[i+1] = {text = name, arg1 = id, func = selectLootSpec, checked = checkLootSpec}
		end
	end
end

info.onMouseUp = function(self, btn)
	local specIndex = GetSpecialization()
	if not specIndex or specIndex == 5 then return end

	if btn == "LeftButton" then
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame(2)
	else
		if not menuList[1].created then
			BuildSpecMenu()
			menuList[1].created = true
		end
		menuList[3].menuList[1].text = format(LOOT_SPECIALIZATION_DEFAULT, select(2, GetSpecializationInfo(specIndex)))
		EasyMenu(menuList, B.EasyMenu, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end