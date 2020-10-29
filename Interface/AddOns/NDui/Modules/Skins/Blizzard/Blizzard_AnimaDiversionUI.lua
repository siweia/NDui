local _, ns = ...
local B, C, L, DB = unpack(ns)

local function replaceIconString(self, text)
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
	if DB.isNewPatch then
		replaceIconString(currencyFrame.Quantity)
		hooksecurefunc(currencyFrame.Quantity, "SetText", replaceIconString)
	else
		B.ReskinIcon(currencyFrame.CurrencyIcon)
	end

	if not DB.isNewPatch then
		local infoFrame = frame.SelectPinInfoFrame
		B.StripTextures(infoFrame)
		local bg = B.SetBD(infoFrame)
		bg.__shadow:SetFrameLevel(infoFrame:GetFrameLevel()-1)
		B.Reskin(infoFrame.SelectButton)
		B.ReskinClose(infoFrame.CloseButton)

		hooksecurefunc(infoFrame, "SetupCosts", function(self)
			for currency in self.currencyPool:EnumerateActive() do
				if not currency.bg then
					currency.bg = B.ReskinIcon(currency.CurrencyIcon)
				end
			end
		end)
	end

	B.Reskin(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end