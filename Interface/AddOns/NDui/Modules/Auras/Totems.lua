local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Auras")

-- Style
local totem = {}
local icons = {
	[1] = GetSpellTexture(120217), -- Fire
	[2] = GetSpellTexture(120218), -- Earth
	[3] = GetSpellTexture(120214), -- Water
	[4] = GetSpellTexture(120219), -- Air
}

local function TotemsGo()
	local Totembar = CreateFrame("Frame", nil, UIParent)
	Totembar:SetSize(C.Auras.IconSize, C.Auras.IconSize)
	for i = 1, 4 do
		totem[i] = CreateFrame("Button", nil, Totembar, "SecureActionButtonTemplate")
		totem[i]:SetSize(C.Auras.IconSize, C.Auras.IconSize)
		if i == 1 then
			totem[i]:SetPoint("CENTER", Totembar)
		else
			totem[i]:SetPoint("LEFT", totem[i-1], "RIGHT", 5, 0)
		end
		B.CreateIF(totem[i], true, true)
		totem[i].Icon:SetTexture(icons[i])
		totem[i]:SetAlpha(.3)
		if NDuiDB["Auras"]["DestroyTotems"] then
			totem[i]:RegisterForClicks("RightButtonUp")
			totem[i]:SetAttribute("type2", "macro")
			totem[i]:SetAttribute("macrotext", "/click TotemFrameTotem"..SHAMAN_TOTEM_PRIORITIES[i].." RightButton")
		end

		totem[i]:SetScript("OnEnter", function(self)
			if not self.spellID then return end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
			GameTooltip:ClearLines()
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		end)
		totem[i]:SetScript("OnLeave", GameTooltip_Hide)
	end
	B.Mover(Totembar, L["Totembar"], "Totems", C.Auras.TotemsPos, 140, 32)
end

local function updateGlow(self)
	local timer = self.start + self.dur - GetTime()
	if timer > 0 and timer < .8 then
		ActionButton_ShowOverlayGlow(self)
	else
		ActionButton_HideOverlayGlow(self)
	end
end

local function updateTotem()
	for slot = 1, 4 do
		local haveTotem, name, start, dur, tex = GetTotemInfo(slot)
		local Totem = totem[slot]
		local spellID = select(7, GetSpellInfo(name))
		Totem.start = start
		Totem.dur = dur
		Totem.spellID = haveTotem and spellID

		if haveTotem and dur > 0 then
			Totem:SetAlpha(1)
			Totem.Icon:SetTexture(tex)
			Totem.CD:SetCooldown(start, dur)
			Totem.CD:Show()
			Totem:SetScript("OnUpdate", updateGlow)
		else
			Totem:SetAlpha(.3)
			Totem.Icon:SetTexture(icons[slot])
			Totem.CD:Hide()
			Totem:SetScript("OnUpdate", nil)
			ActionButton_HideOverlayGlow(Totem)
		end
	end
end

function module:Totems()
	if not NDuiDB["Auras"]["Totems"] then return end

	TotemsGo()
	B:RegisterEvent("PLAYER_TOTEM_UPDATE", updateTotem)
end