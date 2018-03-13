local B, C, L, DB = unpack(select(2, ...))
if DB.MyClass ~= "MONK" then return end

-- Monk Statue
local IconSize = C.Auras.IconSize - 2
local bu
local function StatueGo()
	if bu then bu:Show() return end

	bu = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	bu:SetSize(IconSize, IconSize)
	B.CreateIF(bu, true)
	bu:RegisterForClicks("RightButtonUp")
	bu:SetAttribute("type2", "macro")
	bu:SetAttribute("macrotext", "/click TotemFrameTotem1 RightButton")

	B.Mover(bu, L["Statue"], "Statue", C.Auras.StatuePos, IconSize, IconSize)
end

local f = NDui:EventFrame{"PLAYER_LOGIN", "PLAYER_TALENT_UPDATE"}
f:SetScript("OnEvent", function(self, event)
	if not NDuiDB["Auras"]["Statue"] then
		self:UnregisterAllEvents()
		return
	end

	if event == "PLAYER_LOGIN" or event == "PLAYER_TALENT_UPDATE" then
		if (GetSpecializationInfo(GetSpecialization()) == 270 and IsPlayerSpell(115313)) or IsPlayerSpell(115315) then
			StatueGo()
			bu:SetAlpha(.3)
			bu.CD:SetCooldown(0, 0)
			if IsPlayerSpell(115313) then
				bu.Icon:SetTexture(GetSpellTexture(115313))
			else
				bu.Icon:SetTexture(GetSpellTexture(115315))
			end
			self:RegisterEvent("PLAYER_TOTEM_UPDATE")
		else
			if bu then bu:Hide() end
			self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
		end
	elseif event == "PLAYER_TOTEM_UPDATE" then
		local haveTotem, _, start, dur = GetTotemInfo(1)
		if haveTotem then
			bu.CD:SetCooldown(start, dur)
			bu:SetAlpha(1)
		else
			bu.CD:SetCooldown(0, 0)
			bu:SetAlpha(.3)
		end
		bu:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:ClearLines()
			GameTooltip:SetTotem(1)
			GameTooltip:Show()
		end)
		bu:SetScript("OnLeave", GameTooltip_Hide)
	end
end)