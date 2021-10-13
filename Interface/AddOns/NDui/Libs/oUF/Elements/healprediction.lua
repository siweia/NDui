local _, ns = ...
local oUF = ns.oUF

local function UpdateFillBar(frame, previousTexture, bar, amount, maxHealth)
	if amount == 0 then
		bar:Hide()
		if bar.overlay then
			bar.overlay:Hide()
		end
		return previousTexture
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", 0, 0)
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", 0, 0)

	local totalWidth, totalHeight = frame.Health:GetSize()
	local barSize = (amount / maxHealth) * totalWidth
	bar:SetWidth(barSize)
	bar:Show()
	if bar.overlay then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize)
		bar.overlay:Show()
	end
	return bar
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local hp = self.HealPredictionAndAbsorb
	if(hp.PreUpdate) then hp:PreUpdate(unit) end

	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local absorb = UnitGetTotalAbsorbs(unit) or 0
	local healAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

	local overHealAbsorb = false
	if(health < healAbsorb) then
		healAbsorb = health
		overHealAbsorb = true
	end

	if(health - healAbsorb + allIncomingHeal > maxHealth * hp.maxOverflow) then
		allIncomingHeal = maxHealth * hp.maxOverflow - health + healAbsorb
	end

	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
		allIncomingHeal = 0
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	local overAbsorb = false
	if(health - healAbsorb + allIncomingHeal + absorb >= maxHealth or health + absorb >= maxHealth) then
		if absorb > 0 then
			overAbsorb = true
		end

		if(allIncomingHeal > healAbsorb) then
			absorb = math.max(0, maxHealth - (health - healAbsorb + allIncomingHeal))
		else
			absorb = math.max(0, maxHealth - health)
		end
	end

	if hp.overAbsorbGlow then
		if overAbsorb then
			hp.overAbsorbGlow:Show()
		else
			hp.overAbsorbGlow:Hide()
		end
	end

	local previousTexture = self.Health:GetStatusBarTexture()

	previousTexture = UpdateFillBar(self, previousTexture, hp.myBar, myIncomingHeal, maxHealth)
	previousTexture = UpdateFillBar(self, previousTexture, hp.otherBar, allIncomingHeal, maxHealth)
	if hp.absorbBar then
		previousTexture = UpdateFillBar(self, previousTexture, hp.absorbBar, absorb, maxHealth)
	end
	if hp.healAbsorbBar then
		if healAbsorb > 0 then
			hp.healAbsorbBar:SetMinMaxValues(0, maxHealth)
			hp.healAbsorbBar:SetValue(healAbsorb)
			hp.healAbsorbBar:Show()
		else
			hp.healAbsorbBar:Hide()
		end
	end
	if hp.overHealAbsorbGlow then
		if overHealAbsorb then
			hp.overHealAbsorbGlow:Show()
		else
			hp.overHealAbsorbGlow:Hide()
		end
	end

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

		self:RegisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
		self:RegisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)

		if(not hp.maxOverflow) then
			hp.maxOverflow = 1.05
		end

		if(hp.myBar and hp.myBar:IsObjectType'Texture' and not hp.myBar:GetTexture()) then
			hp.myBar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(hp.otherBar and hp.otherBar:IsObjectType'Texture' and not hp.otherBar:GetTexture()) then
			hp.otherBar:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end
		if(hp.absorbBar and hp.absorbBar:IsObjectType'Texture' and not hp.absorbBar:GetTexture()) then
			hp.absorbBar:SetTexture([[Interface\TargetingFrame\UI-Texture]])
		end
		if(hp.overAbsorbGlow and hp.overAbsorbGlow:IsObjectType'Texture' and not hp.overAbsorbGlow:GetTexture()) then
			hp.overAbsorbGlow:SetTexture([[Interface\RaidFrame\Shield-Overshield]])
		end
		if(hp.absorbBar) then
			hp.absorbBar.overlay = hp.absorbBarOverlay
		end

		return true
	end
end

local function Disable(self)
	local hp = self.HealPredictionAndAbsorb
	if(hp) then
		hp.myBar:Hide()
		hp.otherBar:Hide()
		hp.absorbBar:Hide()
		hp.absorbBarOverlay:Hide()
		hp.overAbsorbGlow:Hide()
		hp.healAbsorbBar:Hide()
		hp.overHealAbsorbGlow:Hide()

		self:UnregisterEvent('UNIT_HEAL_PREDICTION', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Path)
		self:UnregisterEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', Path)
	end
end

oUF:AddElement('HealPredictionAndAbsorb', Path, Enable, Disable)