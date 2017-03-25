local B, C, L, DB = unpack(select(2, ...))
local oUF = NDui.oUF or oUF
if not oUF then return end
assert(oUF, 'oUF Experience was unable to locate oUF install')

local function SetTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 5)
	GameTooltip:ClearLines()
	if UnitLevel("player") < MAX_PLAYER_LEVEL then
		GameTooltip:AddLine(LEVEL.." "..UnitLevel("player"), 0,.6,1)
		local xp, mxp, rxp = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		GameTooltip:AddDoubleLine(XP..":", xp.."/"..mxp.." ("..floor(xp/mxp*100).."%)", .6,.8,1, 1,1,1)
		if rxp then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..":", "+"..rxp.." ("..floor(rxp/mxp*100).."%)", .6,.8,1, 1,1,1)
		end
		if IsXPUserDisabled() then GameTooltip:AddLine("|cffff0000"..XP..LOCKED) end
	end
	if HasArtifactEquipped() then
		if UnitLevel("player") < MAX_PLAYER_LEVEL then
			GameTooltip:AddLine(" ")
		end
		local _, _, name, _, totalXP, pointsSpent = C_ArtifactUI.GetEquippedArtifactInfo()
		local num, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
		GameTooltip:AddLine(name.." ("..format(SPELLBOOK_AVAILABLE_AT, pointsSpent)..")", 0,.6,1)
		GameTooltip:AddDoubleLine(ARTIFACT_POWER, totalXP.." ("..num..")", .6,.8,1, 1,1,1)
		GameTooltip:AddDoubleLine(L["Next Trait"], xp.."/"..xpForNextPoint.." ("..floor(xp/xpForNextPoint*100).."%)", .6,.8,1, 1,1,1)
	end
	GameTooltip:Show()
end

local function Update(self, event, owner)
	if(event == 'UNIT_PET' and owner ~= 'player') then return end
	local unit = self.unit
	local experience = self.Experience
	-- Conditional hiding
	if(unit == 'player') then
		if(UnitLevel('player') == MAX_PLAYER_LEVEL) and (not HasArtifactEquipped()) then
			return experience:Hide()
		end
	else
		return experience:Hide()
	end

	if UnitLevel("player") < MAX_PLAYER_LEVEL then
		local min, max = UnitXP("player"), UnitXPMax("player")
		experience:SetStatusBarColor(0, .7, 1)
		experience:SetMinMaxValues(0, max)
		experience:SetValue(min)
		experience:Show()

		if(experience.Text) then
			experience.Text:SetFormattedText('%d / %d', min, max)
		end

		if(experience.Rested) then
			local rested = GetXPExhaustion()
			if(unit == 'player' and rested and rested > 0) then
				experience.Rested:SetMinMaxValues(0, max)
				experience.Rested:SetValue(math.min(min + rested, max))
				experience.rested = rested
			else
				experience.Rested:SetMinMaxValues(0, 1)
				experience.Rested:SetValue(0)
				experience.rested = nil
			end
		end
	elseif HasArtifactEquipped() then
		local _, _, _, _, totalXP, pointsSpent = C_ArtifactUI.GetEquippedArtifactInfo()
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
		experience:SetStatusBarColor(.9, .8, .6)
		experience:SetMinMaxValues(0, xpForNextPoint)
		experience:SetValue(xp)
		experience:Show()

		if(experience.Text) then experience.Text:Hide() end
		if(experience.Rested) then experience.Rested:Hide() end
	end

	if(experience.PostUpdate) then
		return experience:PostUpdate(unit, min, max)
	end
end

local function Enable(self, unit)
	local experience = self.Experience
	if(experience) then
		local Update = experience.Update or Update

		self:RegisterEvent('PLAYER_XP_UPDATE', Update)
		self:RegisterEvent('PLAYER_LEVEL_UP', Update)
		self:RegisterEvent('ARTIFACT_XP_UPDATE', Update)
		self:RegisterEvent('UNIT_INVENTORY_CHANGED', Update)
		self:RegisterEvent('UNIT_PET', Update)

		if(experience.Rested) then
			self:RegisterEvent('UPDATE_EXHAUSTION', Update)
		end

		if(experience.Tooltip) then
			experience:EnableMouse(true)
			experience:HookScript('OnLeave', GameTooltip_Hide)
			experience:HookScript('OnEnter', SetTooltip)
		end

		if(not experience:GetStatusBarTexture()) then
			experience:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	local experience = self.Experience
	if(experience) then
		local Update = experience.Update or Update

		self:UnregisterEvent('PLAYER_XP_UPDATE', Update)
		self:UnregisterEvent('PLAYER_LEVEL_UP', Update)
		self:UnregisterEvent('ARTIFACT_XP_UPDATE', Update)
		self:UnregisterEvent('UNIT_INVENTORY_CHANGED', Update)
		self:UnregisterEvent('UNIT_PET', Update)

		if(experience.Rested) then
			self:UnregisterEvent('UPDATE_EXHAUSTION', Update)
		end

		if(hunterPlayer) then
			self:UnregisterEvent('UNIT_PET_EXPERIENCE', Update)
		end
	end
end

oUF:AddElement('Experience', Update, Enable, Disable)