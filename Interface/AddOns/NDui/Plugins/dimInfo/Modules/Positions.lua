local _, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.Positions == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)
	Stat:EnableMouse(true)
	Stat:SetHitRectInsets(0, 0, 0, -10)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.PositionsPoint))
	Stat:SetAllPoints(Text)

	local colorT = {
		sanctuary = {SANCTUARY_TERRITORY, {.41, .8, .94}};
		arena = {FREE_FOR_ALL_TERRITORY, {1, .1, .1}};
		friendly = {FACTION_CONTROLLED_TERRITORY, {.1, 1, .1}};
		hostile = {FACTION_CONTROLLED_TERRITORY, {1, .1, .1}};
		contested = {CONTESTED_TERRITORY, {1, .7, 0}};
		combat = {COMBAT_ZONE, {1, .1, .1}};
		neutral = {format(FACTION_CONTROLLED_TERRITORY,FACTION_STANDING_LABEL4), {1, .93, .76}}
	}

	local subzone, zone, pvp
	local coordX, coordY = 0, 0

	local function formatCoords()
		return format("%.1f, %.1f", coordX*100, coordY*100)
	end

	local function OnEvent()
		subzone, zone, pvp = GetSubZoneText(), GetZoneText(), {GetZonePVPInfo()}
		if not pvp[1] then pvp[1] = "neutral" end
		local r, g, b = unpack(colorT[pvp[1]][2])
		Text:SetText((subzone ~= "") and subzone or zone)
		Text:SetTextColor(r, g, b)
	end

	Stat:RegisterEvent("ZONE_CHANGED")
	Stat:RegisterEvent("ZONE_CHANGED_INDOORS")
	Stat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnEvent", OnEvent)

	Stat:SetScript("OnEnter",function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
		GameTooltip:ClearLines()

		if GetPlayerMapPosition("player") then
			self.Timer = 0
			self:SetScript("OnUpdate", function(self, elapsed)
				self.Timer = self.Timer + elapsed
				if self.Timer > .1 then
					self.Timer = 0
					coordX, coordY = GetPlayerMapPosition("player")
					self:GetScript("OnEnter")(self)
				end
			end)
		end
		GameTooltip:AddLine(format("%s |cffffffff(%s)", zone, formatCoords()), 0,.6,1, 1,1,1)

		if pvp[1] and not IsInInstance() then
			local r, g, b = unpack(colorT[pvp[1]][2])
			if subzone and subzone ~= zone then 
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(subzone, r, g, b)
			end
			GameTooltip:AddLine(format(colorT[pvp[1]][1], pvp[3] or ""), r, g, b)
		end

		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.LeftButton..ns.infoL["WorldMap"], 1,1,1, .6,.8,1)
		if GetCurrentMapAreaID() >= 1190 and GetCurrentMapAreaID() <= 1201 then
			GameTooltip:AddDoubleLine(" ", init.ScrollButton..ns.infoL["Search Invasion Group"], 1,1,1, .6,.8,1)
		end
		GameTooltip:AddDoubleLine(" ", init.RightButton..ns.infoL["Send My Pos"], 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)
	Stat:SetScript("OnLeave", function()
		Stat:SetScript("OnUpdate", nil)
		GameTooltip:Hide()
	end)
	Stat:SetScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			ToggleFrame(WorldMapFrame)
		elseif btn == "MiddleButton" and GetCurrentMapAreaID() >= 1190 and GetCurrentMapAreaID() <= 1201 then
			PVEFrame_ShowFrame("GroupFinderFrame", LFGListPVEStub)
			LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 6, 0)
			LFGListCategorySelection_StartFindGroup(LFGListFrame.CategorySelection, zone)
		else
			ChatFrame_OpenChat(format("%s: %s (%s)", ns.infoL["My Position"], zone, formatCoords()), chatFrame)
		end
	end)
end