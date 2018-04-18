local B, C, L, DB = unpack(select(2, ...))
if not C.Infobar.Spec then return end

local module = NDui:GetModule("Infobar")
local info = module:RegisterInfobar(C.Infobar.SpecPos)

local function addIcon(texture)
	texture = texture and "|T"..texture..":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local menuFrame = CreateFrame("Frame", "SpecInfobarMenu", info, "UIDropDownMenuTemplate")
local menuList = {
	{text = CHOOSE_SPECIALIZATION, isTitle = true, notCheckable = true},
	{text = SPECIALIZATION, hasArrow = true, notCheckable = true},
	{text = SELECT_LOOT_SPECIALIZATION, hasArrow = true, notCheckable = true},
}

info.eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED",
}

info.onEvent = function(self)
	if GetSpecialization() then
		local _, name, _, icon = GetSpecializationInfo(GetSpecialization())
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

info.onEnter = function(self)
	if not GetSpecialization() then return end
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 15)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0,.6,1)
	GameTooltip:AddLine(" ")

	local _, specName, _, specIcon = GetSpecializationInfo(GetSpecialization())
	GameTooltip:AddLine(addIcon(specIcon).." "..specName, 1,1,1)

	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddDoubleLine(" ", DB.MyColor..name.." "..addIcon(icon))
			end
		end
	end

	if UnitLevel("player") == 110 then
		local _, _, texture = GetCurrencyInfo(104)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(addIcon(texture).." "..PVP_TALENTS, 1,1,1)

		for t = 1, MAX_PVP_TALENT_TIERS do
			for c = 1, 3 do
				local _, name, icon, selected, _, _, unlocked = GetPvpTalentInfo(t, c, 1)
				if selected and unlocked then
					GameTooltip:AddDoubleLine(" ", DB.MyColor..name.." "..addIcon(icon))
				end
			end
		end
	end

	GameTooltip:AddDoubleLine(" ", DB.LineString)
	GameTooltip:AddDoubleLine(" ", DB.LeftButton..L["SpecPanel"].." ", 1,1,1, .6,.8,1)
	GameTooltip:AddDoubleLine(" ", DB.RightButton..L["Change Spec"].." ", 1,1,1, .6,.8,1)
	GameTooltip:Show()
end

info.onLeave = function() GameTooltip:Hide() end

local function clickFunc(i, isLoot, isPet)
	if not i then return end
	if isLoot then
		SetLootSpecialization(i)
	else
		SetSpecialization(i, isPet)
	end
	DropDownList1:Hide()
end

info.onMouseUp = function(self, btn)
	if not GetSpecialization() then return end
	if btn == "LeftButton" then
		ToggleTalentFrame(2)
	else
		menuList[2].menuList = {{}, {}, {}, {}}
		menuList[3].menuList = {{}, {}, {}, {}, {}}
		local specList, lootList = menuList[2].menuList, menuList[3].menuList
		local spec, specName = GetSpecializationInfo(GetSpecialization())
		local lootSpec = GetLootSpecialization()
		lootList[1] = {text = format(LOOT_SPECIALIZATION_DEFAULT, specName), func = function() clickFunc(0, true) end, checked = lootSpec == 0 and true or false}

		for i = 1, 4 do
			local id, name = GetSpecializationInfo(i)
			if id then
				specList[i].text = name
				if id == spec then
					specList[i].func = function() clickFunc() end
					specList[i].checked = true
				else
					specList[i].func = function() clickFunc(i) end
					specList[i].checked = false
				end
				lootList[i+1] = {text = name, func = function() clickFunc(id, true) end, checked = id == lootSpec and true or false}
			else
				specList[i] = nil
				lootList[i+1] = nil
			end
		end

		do
			local _, myclass = UnitClass("player")
			if myclass == "HUNTER" and IsPetActive() then
				menuList[4] = {text = PET..SPECIALIZATION, hasArrow = true, notCheckable = true}
				menuList[4].menuList = {{}, {}, {}}
				local petList = menuList[4].menuList
				local spec = GetSpecializationInfo(GetSpecialization(false, true), false, true)
				for i = 1, 3 do
					local id, name = GetSpecializationInfo(i, false, true)
					petList[i].text = name
					if id == spec then
						petList[i].func = function() clickFunc() end
						petList[i].checked = true
					else
						petList[i].func = function() clickFunc(i, false, true) end
						petList[i].checked = false
					end
				end
			else
				menuList[4] = nil
			end
		end

		EasyMenu(menuList, menuFrame, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end