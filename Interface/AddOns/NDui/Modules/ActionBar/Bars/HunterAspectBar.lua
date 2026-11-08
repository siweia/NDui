local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local pairs, sort, tinsert, max = pairs, sort, tinsert, math.max
local InCombatLockdown, IsPlayerSpell = InCombatLockdown, IsPlayerSpell
local GetSpellName, GetSpellTexture = C_Spell.GetSpellName, C_Spell.GetSpellTexture
local GetAuraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetAura = UnitAura

-- Classic aspect ranks; IDs the client does not know are skipped, so the bar
-- only ever shows what the hunter has actually learned.
local aspects = {
	[1] = {spellID = 13165},	-- Aspect of the Hawk
	[2] = {spellID = 415423},	-- Aspect of the Viper (custom)
	[3] = {spellID = 13163},	-- Aspect of the Monkey
	[4] = {spellID = 5118},		-- Aspect of the Cheetah
	[5] = {spellID = 13159},	-- Aspect of the Pack
	[6] = {spellID = 13161},	-- Aspect of the Beast
	[7] = {spellID = 20043},	-- Aspect of the Wild
	[8] = {spellID = 409580},	-- Aspect of the Lionheart (custom)
	[9] = {spellID = 469145},	-- Aspect of the Falcon (custom)
}

local aspectButtons = {}
local aspectByName, aspectBySpell = {}, {}
local aspectFrame

local function IsAspectKnown(spellID)
	if IsPlayerSpell and IsPlayerSpell(spellID) then return true end
	return C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID) or false
end

-- The buff of a ranked aspect carries the rank's ID, not the base ID, so the
-- name is the reliable match. Aura data is read in a single pass; a self-cast
-- aura wins over another hunter's group aspect (Pack/Wild), and an unknown
-- source still counts so a missing unit token can never drop the highlight.
local function FindActiveAspect()
	if not GetAuraData and not GetAura then return end

	local fallback
	for i = 1, 40 do
		local name, spellID, source
		if GetAuraData then
			local aura = GetAuraData("player", i, "HELPFUL")
			if not aura then break end
			name, spellID, source = aura.name, aura.spellId, aura.sourceUnit
		else
			local auraName, _, _, _, _, _, caster = GetAura("player", i, "HELPFUL")
			if not auraName then break end
			name, source = auraName, caster
		end

		local button
		if name then button = aspectByName[name] end
		if not button and spellID then button = aspectBySpell[spellID] end

		if button then
			if source and source ~= "" and source ~= "player" then
				fallback = fallback or button
			else
				return button
			end
		end
	end

	return fallback
end

function Bar:UpdateAspectCooldown()
	local cooldown = C_Spell.GetSpellCooldown(self.spellID)
	if cooldown and cooldown.isActive then
		local durationObject
		if self.CD.SetCooldownFromDurationObject and C_Spell.GetSpellCooldownDuration then
			durationObject = C_Spell.GetSpellCooldownDuration(self.spellID)
		end
		if durationObject then
			self.CD:SetCooldownFromDurationObject(durationObject)
		else
			self.CD:SetCooldown(cooldown.startTime, cooldown.duration)
		end
		self.CD:Show()
	else
		self.CD:Hide()
	end
end

function Bar:CreateAspectButton(spellID, index)
	local name, icon = GetSpellName(spellID), GetSpellTexture(spellID)
	if not name then return end

	local size = C.db["Actionbar"]["AspectSize"] or 30
	local button = CreateFrame("Button", "$parentButton"..index, aspectFrame, "SecureActionButtonTemplate")
	button:SetSize(size, size)
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", name)
	button:RegisterForClicks("AnyUp", "AnyDown")
	B.PixelIcon(button, icon, true)
	B.CreateSD(button.bg)
	B.AddTooltip(button, "ANCHOR_TOP", spellID)

	button.CD = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.CD:SetAllPoints()
	if button.CD.SetDrawEdge then button.CD:SetDrawEdge(false) end
	button.spellID = spellID
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", Bar.UpdateAspectCooldown)

	-- Highlight of the active aspect
	button.cover = button:CreateTexture(nil, "ARTWORK", nil, 7)
	button.cover:SetAllPoints(button.Icon)
	button.cover:SetColorTexture(1, 1, 1, .18)
	button.cover:Hide()

	aspectByName[name] = button
	aspectBySpell[spellID] = button
	tinsert(aspectButtons, {button, index, name, spellID})
	return button
end

local function sortButtons(a, b)
	return a[2] < b[2]
end

function Bar:UpdateAspectAnchor()
	sort(aspectButtons, sortButtons)

	local prevButton
	for _, value in pairs(aspectButtons) do
		local button = value[1]
		button:ClearAllPoints()
		if not prevButton then
			button:SetPoint("TOPLEFT", 3, -3)
		elseif C.db["Actionbar"]["VerticleAspect"] then
			button:SetPoint("TOP", prevButton, "BOTTOM", 0, -3)
		else
			button:SetPoint("LEFT", prevButton, "RIGHT", 3, 0)
		end
		prevButton = button
	end
end

function Bar:UpdateAspectStatus()
	if not aspectFrame then return end

	local size = C.db["Actionbar"]["AspectSize"] or 30
	local num = max(#aspectButtons, 1)
	local length = size*num + 3*(num+1)
	local thickness = size + 3*2

	if C.db["Actionbar"]["VerticleAspect"] then
		aspectFrame:SetSize(thickness, length)
	else
		aspectFrame:SetSize(length, thickness)
	end
	aspectFrame.mover:SetSize(aspectFrame:GetSize())

	for _, value in pairs(aspectButtons) do
		value[1]:SetSize(size, size)
	end
	Bar:UpdateAspectAnchor()
end

function Bar:CheckKnownAspects()
	if not aspectFrame then return end
	if InCombatLockdown() then return end -- secure buttons cannot be created in combat

	for index, value in pairs(aspects) do
		if not value.known and IsAspectKnown(value.spellID) then
			if Bar:CreateAspectButton(value.spellID, index) then
				value.known = true
			end
		end
	end

	Bar:UpdateAspectStatus()
	Bar:CheckActiveAspect("player")
end

function Bar:CheckActiveAspect(unit)
	if unit ~= "player" or not aspectFrame or not aspectFrame:IsShown() then return end

	local active = FindActiveAspect()
	for _, value in pairs(aspectButtons) do
		local button = value[1]
		local isActive = button == active
		button.cover:SetShown(isActive)
		if isActive then
			button.bg:SetBackdropBorderColor(1, .8, 0)
		else
			B.SetBorderColor(button.bg)
		end
	end
end

-- Aura data is not always refreshed yet while the event is being handled, so
-- the check runs one frame later; events of the same frame collapse into one.
local checkQueued
local function QueueActiveCheck()
	if checkQueued then return end
	checkQueued = true

	local function run()
		checkQueued = nil
		Bar:CheckActiveAspect("player")
	end

	if C_Timer and C_Timer.After then
		C_Timer.After(0, run)
	else
		run()
	end
end

-- UNIT_AURA passes (event, unit); some clients omit the unit, so it is queued
-- in that case as well.
local function OnUnitAura(event, unit)
	if unit and unit ~= "player" then return end
	QueueActiveCheck()
end

function Bar:ToggleAspectBar()
	if not aspectFrame then return end

	if C.db["Actionbar"]["AspectBar"] then
		aspectFrame:Show()
		aspectFrame.mover.isDisable = false
		Bar:CheckKnownAspects()
		Bar:CheckActiveAspect("player")
		B:RegisterEvent("SPELLS_CHANGED", Bar.CheckKnownAspects)
		B:RegisterEvent("PLAYER_REGEN_ENABLED", Bar.CheckKnownAspects)
		B:RegisterEvent("UNIT_AURA", OnUnitAura)
	else
		B:UnregisterEvent("SPELLS_CHANGED", Bar.CheckKnownAspects)
		B:UnregisterEvent("PLAYER_REGEN_ENABLED", Bar.CheckKnownAspects)
		B:UnregisterEvent("UNIT_AURA", OnUnitAura)
		aspectFrame:Hide()
		aspectFrame.mover.isDisable = true
		aspectFrame.mover:Hide()
	end
end

function Bar:HunterAspectBar()
	if DB.MyClass ~= "HUNTER" then return end
	if aspectFrame then
		Bar:ToggleAspectBar()
		return
	end

	local size = C.db["Actionbar"]["AspectSize"] or 30
	aspectFrame = CreateFrame("Frame", "NDuiHunterAspectFrame", UIParent)
	aspectFrame:SetSize(size + 6, size + 6)
	aspectFrame.mover = B.Mover(aspectFrame, L["AspectBar"], "AspectBar", {"BOTTOMLEFT", 415, 25}, size + 6, size + 6)

	Bar:ToggleAspectBar()
end
