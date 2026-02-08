local _, ns = ...
local oUF = ns.oUF

local function UpdateFillBar(previousTexture, bar, amount, ratio)
	if amount <= 0 then
		bar:Hide()
		return previousTexture
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", 0, 0)
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", 0, 0)
	bar:SetWidth(amount * ratio)
	bar:Show()
	return bar
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local hp = self.HealPredictionAndAbsorb
	if(hp.PreUpdate) then hp:PreUpdate(unit) end

	local guid = UnitGUID(unit)

	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
	local ratio = self.Health:GetWidth() / (maxHealth + 0.00001)

	if(health + allIncomingHeal > maxHealth * hp.maxOverflow) then
		allIncomingHeal = maxHealth * hp.maxOverflow - health
	end

	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
		allIncomingHeal = 0
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	if UnitIsDeadOrGhost(unit) then
		myIncomingHeal, allIncomingHeal = 0, 0
	end

	local previousTexture = self.Health:GetStatusBarTexture()
	previousTexture = UpdateFillBar(previousTexture, hp.myBar, myIncomingHeal, ratio)
	previousTexture = UpdateFillBar(previousTexture, hp.otherBar, allIncomingHeal, ratio)

	if(hp.PostUpdate) then
		return hp:PostUpdate(unit)
	end
end

local function Path(self, ...)
	return (self.HealPredictionAndAbsorb.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local hp = self.HealPredictionAndAbsorb
	if(hp) then
		hp.__owner = self
		hp.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)

		if(not hp.maxOverflow) then
			hp.maxOverflow = 1.05
		end

		if(hp.myBar and hp.myBar:IsObjectType'Texture' and not hp.myBar:GetTexture()) then
			hp.myBar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(hp.otherBar and hp.otherBar:IsObjectType'Texture' and not hp.otherBar:GetTexture()) then
			hp.otherBar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	local hp = self.HealPredictionAndAbsorb
	if(hp) then
		hp.myBar:Hide()
		hp.otherBar:Hide()

		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)
	end
end

oUF:AddElement('HealPredictionAndAbsorb', Path, Enable, Disable)