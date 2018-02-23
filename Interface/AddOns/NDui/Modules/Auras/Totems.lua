local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "SHAMAN" then return end

-- Style
local Totembar, totem, debugCheck = CreateFrame("Frame", nil, UIParent), {}
local icons = {
	[1] = 120217, -- Fire
	[2] = 120218, -- Earth
	[3] = 120214, -- Water
	[4] = 120219, -- Air
}

local function TotemsGo()
	Totembar:SetSize(C.Auras.IconSize, C.Auras.IconSize)
	for i = 1, 4 do
		totem[i] = CreateFrame("Button", nil, Totembar, "SecureActionButtonTemplate")
		totem[i]:SetSize(C.Auras.IconSize, C.Auras.IconSize)
		if i == 1 then
			totem[i]:SetPoint("CENTER", Totembar)
		else
			totem[i]:SetPoint("LEFT", totem[i-1], "RIGHT", 5, 0)
		end
		B.CreateIF(totem[i], true)
		totem[i].Icon:SetTexture(GetSpellTexture(icons[i]))
		totem[i]:SetAlpha(.3)
		if NDuiDB["Auras"]["DestroyTotems"] then
			totem[i]:SetAttribute("type", "macro")
			totem[i]:SetAttribute("macrotext", "/click TotemFrameTotem"..SHAMAN_TOTEM_PRIORITIES[i].." RightButton")
		end
	end
	B.Mover(Totembar, L["Totembar"], "Totems", C.Auras.TotemsPos, 140, 32)
end

-- Function
local f = NDui:EventFrame{"PLAYER_ENTERING_WORLD", "PLAYER_TOTEM_UPDATE"}
f:SetScript("OnEvent", function(self)
	if not NDuiDB["Auras"]["Totems"] then
		self:UnregisterAllEvents()
		return
	end
	if not self.styled then
		TotemsGo()
		self.styled = true
	end
	if self.styled then
		for slot = 1, 4 do
			local haveTotem, name, start, dur, icon = GetTotemInfo(slot)
			local id = select(7, GetSpellInfo(name))
			local Totem = totem[slot]
			if haveTotem and dur > 0 then
				Totem:SetAlpha(1)
				Totem.Icon:SetTexture(icon)
				Totem.CD:SetCooldown(start, dur)
			else
				Totem:SetAlpha(.3)
				Totem.Icon:SetTexture(GetSpellTexture(icons[slot]))
				Totem.CD:SetCooldown(0, 0)
			end

			Totem:SetScript("OnEnter", function(self)
				if not id then return end
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
				GameTooltip:ClearLines()
				GameTooltip:SetSpellByID(id)
				GameTooltip:Show()
			end)
			Totem:SetScript("OnLeave", GameTooltip_Hide)

			Totem:SetScript("OnUpdate", function(self, elapsed)
				local Time = start + dur - GetTime()
				if Time > 0 and Time < .8 then
					ActionButton_ShowOverlayGlow(Totem)
				else
					ActionButton_HideOverlayGlow(Totem)
				end
			end)
		end
	end
end)