local _, ns = ...
local B, C, L, DB = unpack(ns)

function B:ReplaceIconString(text)
	if not text then text = self:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
	if count > 0 then self:SetFormattedText("%s", newText) end
end

C.themes["Blizzard_AnimaDiversionUI"] = function()
	local frame = AnimaDiversionFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)

	local currencyFrame = frame.AnimaDiversionCurrencyFrame.CurrencyFrame
	B.ReplaceIconString(currencyFrame.Quantity)
	hooksecurefunc(currencyFrame.Quantity, "SetText", B.ReplaceIconString)

	B.Reskin(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end