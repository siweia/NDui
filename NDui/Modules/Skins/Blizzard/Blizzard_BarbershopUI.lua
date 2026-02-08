local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BarbershopUI"] = function()
	local function updateCheckState(button, checked)
		if checked then
			button.bg:SetBackdropBorderColor(1, .8, 0)
		else
			button.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local function handleSexButton(button, texcoords)
		if button.bg then return end
		button.bg = B.CreateBDFrame(button, .25)
		button:DisableDrawLayer("OVERLAY")
		button:DisableDrawLayer("BACKGROUND")
		button:GetNormalTexture():SetTexCoord(unpack(texcoords))
		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)

		updateCheckState(button, button:GetChecked())
		hooksecurefunc(button, "SetChecked", updateCheckState)
	end

	hooksecurefunc("BarberShop_UpdateSexSelectors", function()
		handleSexButton(BarberShopFrameMaleButton, {.055, .445, .055, .945})
		handleSexButton(BarberShopFrameFemaleButton, {.555, .945, .055, .945})
	end)

	B.Reskin(BarberShopFrameOkayButton)
	B.Reskin(BarberShopFrameCancelButton)
	B.Reskin(BarberShopFrameResetButton)

	for i = 1, BarberShopFrame:GetNumChildren() do
		local child = select(i, BarberShopFrame:GetChildren())
		if child.Prev then
			B.ReskinArrow(child.Prev, "left")
		end
		if child.Next then
			B.ReskinArrow(child.Next, "right")
		end
	end
end