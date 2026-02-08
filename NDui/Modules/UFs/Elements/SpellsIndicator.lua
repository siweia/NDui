local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local UF = B:GetModule("UnitFrames")

local counterOffsets = {
	["TOPLEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["TOPRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOMLEFT"] = {{6, 1},{"LEFT", "RIGHT", -2, 0}},
	["BOTTOMRIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["LEFT"] = {{6, 1}, {"LEFT", "RIGHT", -2, 0}},
	["RIGHT"] = {{-6, 1}, {"RIGHT", "LEFT", 2, 0}},
	["TOP"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
	["BOTTOM"] = {{0, 0}, {"RIGHT", "LEFT", 2, 0}},
}

function UF:SpellsIndicator_OnUpdate(elapsed)
	B.CooldownOnUpdate(self, elapsed, true)
end

UF.CornerSpells = {}
UF.CornerSpellsByName = {}
function UF:UpdateCornerSpells()
	wipe(UF.CornerSpells)

	for spellID, value in pairs(C.CornerBuffs[DB.MyClass]) do
		local modData = NDuiADB["CornerSpells"][DB.MyClass]
		if not (modData and modData[spellID]) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	for spellID, value in pairs(NDuiADB["CornerSpells"][DB.MyClass]) do
		if next(value) then
			local r, g, b = unpack(value[2])
			UF.CornerSpells[spellID] = {value[1], {r, g, b}, value[3]}
		end
	end

	-- By name
	wipe(UF.CornerSpellsByName)

	for spellID, value in pairs(UF.CornerSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			UF.CornerSpellsByName[name] = value
		end
	end
end

local anchors = {"TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

function UF:CreateSpellsIndicator(self)
	local spellSize = C.db["UFs"]["RaidSpellSize"] or 10

	local buttons = {}
	for _, anchor in pairs(anchors) do
		local button = CreateFrame("Frame", nil, self.Health)
		button:SetFrameLevel(self:GetFrameLevel()+10)
		button:SetSize(spellSize, spellSize)
		button:SetPoint(anchor)
		button:Hide()

		button.icon = button:CreateTexture(nil, "BORDER")
		button.icon:SetAllPoints()
		button.bg = B.ReskinIcon(button.icon)

		button.cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(true)

		button.timer = B.CreateFS(button, 12, "", false, "CENTER", -counterOffsets[anchor][2][3], 0)
		button.count = B.CreateFS(button, 12, "")

		button.anchor = anchor
		buttons[anchor] = button

		UF:RefreshBuffIndicator(button)
	end

	self.SpellsIndicator = buttons

	UF.SpellsIndicator_UpdateOptions(self)
end

function UF:SpellsIndicator_UpdateButton(button, aura, r, g, b)
	if C.db["UFs"]["BuffIndicatorType"] == 3 then
		if aura.duration and aura.duration > 0 then
			button.expiration = aura.expiration
			button:SetScript("OnUpdate", UF.SpellsIndicator_OnUpdate)
		else
			button:SetScript("OnUpdate", nil)
		end
		button.timer:SetTextColor(r, g, b)
	else
		if aura.duration and aura.duration > 0 then
			button.cd:SetCooldown(aura.expiration - aura.duration, aura.duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
		if C.db["UFs"]["BuffIndicatorType"] == 1 then
			button.icon:SetVertexColor(r, g, b)
		else
			button.icon:SetTexture(aura.texture)
		end
	end

	button.count:SetText(aura.count > 1 and aura.count or "")
	button:Show()
end

function UF:SpellsIndicator_HideButtons()
	for _, button in pairs(self.SpellsIndicator) do
		button:Hide()
	end
end

function UF:RefreshBuffIndicator(bu)
	if C.db["UFs"]["BuffIndicatorType"] == 3 then
		local point, anchorPoint, x, y = unpack(counterOffsets[bu.anchor][2])
		bu.timer:Show()
		bu.count:ClearAllPoints()
		bu.count:SetPoint(point, bu.timer, anchorPoint, x, y)
		bu.icon:Hide()
		bu.cd:Hide()
		bu.bg:Hide()
	else
		bu:SetScript("OnUpdate", nil)
		bu.timer:Hide()
		bu.count:ClearAllPoints()
		bu.count:SetPoint("CENTER", unpack(counterOffsets[bu.anchor][1]))
		if C.db["UFs"]["BuffIndicatorType"] == 1 then
			bu.icon:SetTexture(DB.bdTex)
		else
			bu.icon:SetVertexColor(1, 1, 1)
		end
		bu.icon:Show()
		bu.cd:Show()
		bu.bg:Show()
	end
end

function UF:SpellsIndicator_UpdateOptions()
	local spells = self.SpellsIndicator
	if not spells then return end

	for anchor, button in pairs(spells) do
		button:SetScale(C.db["UFs"]["BuffIndicatorScale"])
		UF:RefreshBuffIndicator(button)
	end
end