local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_AnimaDiversionUI"] = function()
	local frame = AnimaDiversionFrame

	B.StripTextures(frame)
	B.SetBD(frame)
	B.ReskinClose(frame.CloseButton)
	frame.AnimaDiversionCurrencyFrame.Background:SetAlpha(0)
	B.ReskinIcon(frame.AnimaDiversionCurrencyFrame.CurrencyFrame.CurrencyIcon)

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

	B.Reskin(frame.ReinforceInfoFrame.AnimaNodeReinforceButton)
end