local _, ns = ...
local B, C, L, DB = unpack(ns)
if not C.Infobar.Spec then return end

local module = B:GetModule("Infobar")
local info = module:RegisterInfobar("Spec", C.Infobar.SpecPos)
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
		local _, name, _, _, pointsSpent = GetTalentTabInfo(i)
		if not name then break end
		if pointsSpent > higher then
			higher = pointsSpent
			text = name
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
		local _, name, _, _, pointsSpent = GetTalentTabInfo(i)
		if not name then break end
		GameTooltip:AddDoubleLine(name, pointsSpent, 1,1,1, 1,.8,0)
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
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame()
	end
end