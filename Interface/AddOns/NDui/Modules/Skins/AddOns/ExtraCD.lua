local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Skins")

function module:ExtraCDSkin()
	if not IsAddOnLoaded("ExtraCD") then return end
	if not NDuiDB["Skins"]["ExtraCD"] then return end

	local ExtraCD = ExtraCD
	hooksecurefunc(ExtraCD, "CreateIcon", function(_, order, bar)
		local btn = bar.btns[order]
		local backdrop = btn:GetBackdrop()
		local icon = backdrop.bgFile

		if not btn.icon then
			btn.icon = btn:CreateTexture(nil, "BORDER")
			btn.icon:SetAllPoints()
			btn.icon:SetTexCoord(unpack(DB.TexCoord))
			btn.HL = btn:CreateTexture(nil, "HIGHLIGHT")
			btn.HL:SetColorTexture(1, 1, 1, .25)
			btn.HL:SetAllPoints(btn.icon)
		end
		btn.icon:SetTexture(icon)
		btn:SetBackdrop(nil)
		B.CreateSD(btn, 4, 4)
	end)
end