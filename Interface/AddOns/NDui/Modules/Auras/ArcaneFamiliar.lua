local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "MAGE" then return end

-- Arcane Familiar
local IconSize = C.Auras.IconSize - 2
local bu
local function FamiliarGo()
	if bu then bu:Show() return end

	bu = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	bu:SetSize(IconSize, IconSize)
	B.CreateIF(bu, true)
	B.CreateAT(bu, 205022)
	bu.Icon:SetTexture(GetSpellTexture(210126))
	bu:SetAttribute("*type*", "macro")
	bu:SetAttribute("macrotext", "/click TotemFrameTotem1 RightButton")
	bu:SetAttribute("macrotext", "/click TotemFrameTotem2 RightButton")

	B.Mover(bu, L["Familiar"], "Familiar", C.Auras.FamiliarPos, IconSize, IconSize)
end

local f = NDui:EventFrame({"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"})
f:SetScript("OnEvent", function(self, event)
	if not NDuiDB["Auras"]["Familiar"] then
		self:UnregisterAllEvents()
		return
	end

	if event == "PLAYER_LOGIN" or event == "PLAYER_TALENT_UPDATE" then
		if GetSpecializationInfo(GetSpecialization()) == 62 and IsPlayerSpell(205022) then
			FamiliarGo()
			bu:SetAlpha(.3)
			self:RegisterEvent("PLAYER_TOTEM_UPDATE")
		else
			if bu then bu:Hide() end
			self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
		end
	elseif event == "PLAYER_TOTEM_UPDATE" then
		local haveTotem, _, start, dur = GetTotemInfo(4)
		if haveTotem then
			bu.CD:SetCooldown(start, dur)
			bu:SetAlpha(1)
		else
			bu.CD:SetCooldown(0, 0)
			bu:SetAlpha(.3)
		end
	end
end)