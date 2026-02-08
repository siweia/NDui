local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")

local pairs, sort, tinsert = pairs, sort, tinsert
local GetSpellInfo, GetSpellCooldown, UnitAura, IsPlayerSpell = GetSpellInfo, GetSpellCooldown, UnitAura, IsPlayerSpell

local aspects = {
	[1] = {spellID = 61846, known = false}, -- 龙鹰
	[2] = {spellID = 13165, known = false}, -- 雄鹰
	[3] = {spellID = 34074, known = false}, -- 蝰蛇
	[4] = {spellID = 13163, known = false}, -- 灵猴
	[5] = {spellID =  5118, known = false}, -- 猎豹
	[6] = {spellID = 13159, known = false}, -- 豹群
	[7] = {spellID = 13161, known = false}, -- 野兽
	[8] = {spellID = 20043, known = false}, -- 野性
}
local numAspects = #aspects
local knownAspect = {}
local aspectButtons = {}
local aspectFrame

function Bar:UpdateAspectCooldown()
	local start, duration = GetSpellCooldown(self.spellID)
	if start > 0 and duration > 0 then
		self.CD:SetCooldown(start, duration)
		self.CD:Show()
	else
		self.CD:Hide()
	end
end

function Bar:CreateAspectButton(spellID, index)
	local name, _, texture = GetSpellInfo(spellID)
	local size = C.db["Actionbar"]["AspectSize"]

	local button = CreateFrame("Button", "$parentButton"..index, aspectFrame, "SecureActionButtonTemplate")
	button:SetSize(size, size)
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", name)
	B.PixelIcon(button, texture, true)
	B.CreateSD(button.bg)
	B.AddTooltip(button, "ANCHOR_TOP", name)

	button.CD = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.CD:SetAllPoints()
	button.CD:SetDrawEdge(false)
	button.spellID = spellID
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", Bar.UpdateAspectCooldown)

	button.cover = button:CreateTexture(nil, "ARTWORK", nil, 5)
	button.cover:SetInside()
	button.cover:SetTexCoord(unpack(DB.TexCoord))
	button.cover:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")

	knownAspect[name] = true
	tinsert(aspectButtons, {button, index, name})
end

local function sortButtons(a, b)
	if a and b then
		return a[2] < b[2]
	end
end

function Bar:UpdateAspectAnchor()
	sort(aspectButtons, sortButtons)

	local prevButton
	for _, value in pairs(aspectButtons) do
		value[1]:ClearAllPoints()
		if not prevButton then
			value[1]:SetPoint("TOPLEFT", 3, -3)
		else
			if C.db["Actionbar"]["VerticleAspect"] then
				value[1]:SetPoint("TOP", prevButton, "BOTTOM", 0, -3)
			else
				value[1]:SetPoint("LEFT", prevButton, "RIGHT", 3, 0)
			end
		end
		prevButton = value[1]
	end
end

function Bar:CheckKnownAspects()
	for index, value in pairs(aspects) do
		if not value.known and IsPlayerSpell(value.spellID) then
			Bar:CreateAspectButton(value.spellID, index)
			value.known = true
		end
	end

	Bar:UpdateAspectAnchor()
end

function Bar:CheckActiveAspect(unit)
	if unit ~= "player" then return end

	local foundAspect
	for i = 1, 40 do
		local name, _, _, _, _, _, caster = UnitAura("player", i)
		if not name then break end
		if knownAspect[name] and caster == "player" then
			foundAspect = name
		end
	end

	for _, value in pairs(aspectButtons) do
		value[1].cover:SetShown(value[3] == foundAspect)
	end
end

function Bar:UpdateAspectStatus()
	if not aspectFrame then return end

	local size = C.db["Actionbar"]["AspectSize"]
	local width, height = size*numAspects + 3*(numAspects+1), size + 3*2
	if C.db["Actionbar"]["VerticleAspect"] then
		aspectFrame:SetSize(height, width)
		aspectFrame.mover:SetSize(height, width)
	else
		aspectFrame:SetSize(width, height)
		aspectFrame.mover:SetSize(width, height)
	end

	for _, value in pairs(aspectButtons) do
		value[1]:SetSize(size, size)
	end
	Bar:UpdateAspectAnchor()
end

function Bar:ToggleAspectBar()
	if not aspectFrame then return end

	if C.db["Actionbar"]["AspectBar"] then
		Bar.CheckKnownAspects()
		B:RegisterEvent("LEARNED_SPELL_IN_TAB", Bar.CheckKnownAspects)
		Bar:CheckActiveAspect("player")
		B:RegisterEvent("UNIT_AURA", Bar.CheckActiveAspect)
		aspectFrame:Show()
	else
		B:UnregisterEvent("LEARNED_SPELL_IN_TAB", Bar.CheckKnownAspects)
		B:UnregisterEvent("UNIT_AURA", Bar.CheckActiveAspect)
		aspectFrame:Hide()
	end
end

function Bar:HunterAspectBar()
	if DB.MyClass ~= "HUNTER" then return end

	local size = C.db["Actionbar"]["AspectSize"] or 50
	local width, height = size*numAspects + 3*(numAspects+1), size + 3*2

	aspectFrame = CreateFrame("Frame", "NDuiHunterAspectFrame", UIParent)
	if C.db["Actionbar"]["VerticleAspect"] then
		aspectFrame:SetSize(height, width)
	else
		aspectFrame:SetSize(width, height)
	end
	aspectFrame.mover = B.Mover(aspectFrame, L["AspectBar"], "AspectBar", {"BOTTOMLEFT", 415, 25})

	Bar:ToggleAspectBar()
end