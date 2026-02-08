local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BindingUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	local KeyBindingFrame = KeyBindingFrame

	KeyBindingFrame.header:DisableDrawLayer("BACKGROUND")
	KeyBindingFrame.header:DisableDrawLayer("BORDER")
	KeyBindingFrame.scrollFrame.scrollBorderTop:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderBottom:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollFrameScrollBarBackground:SetTexture("")
	B.StripTextures(KeyBindingFrame.categoryList)
	KeyBindingFrame.bindingsContainer:HideBackdrop()

	B.StripTextures(KeyBindingFrame)
	B.SetBD(KeyBindingFrame)
	B.Reskin(KeyBindingFrame.defaultsButton)
	B.Reskin(KeyBindingFrame.unbindButton)
	B.Reskin(KeyBindingFrame.okayButton)
	B.Reskin(KeyBindingFrame.cancelButton)
	B.ReskinCheck(KeyBindingFrame.characterSpecificButton)
	B.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)
	KeyBindingFrameScrollFrame.scrollFrameScrollBarBackground:Hide()

	for i = 1, KEY_BINDINGS_DISPLAYED do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
	end

	hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(_, button)
		if not button.styled then
			local selected = button.selectedHighlight
			selected:SetTexture(DB.bdTex)
			selected:SetPoint("TOPLEFT", C.mult, -C.mult)
			selected:SetPoint("BOTTOMRIGHT", -C.mult, C.mult)
			selected:SetColorTexture(r, g, b, .25)
			B.Reskin(button)

			button.styled = true
		end
	end)

	KeyBindingFrame.header.text:ClearAllPoints()
	KeyBindingFrame.header.text:SetPoint("TOP", KeyBindingFrame, "TOP", 0, -8)
	KeyBindingFrame.unbindButton:ClearAllPoints()
	KeyBindingFrame.unbindButton:SetPoint("BOTTOMRIGHT", -207, 16)
	KeyBindingFrame.okayButton:ClearAllPoints()
	KeyBindingFrame.okayButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.unbindButton, "BOTTOMRIGHT", 1, 0)
	KeyBindingFrame.cancelButton:ClearAllPoints()
	KeyBindingFrame.cancelButton:SetPoint("BOTTOMLEFT", KeyBindingFrame.okayButton, "BOTTOMRIGHT", 1, 0)

	local line = KeyBindingFrame:CreateTexture(nil, "ARTWORK")
	line:SetSize(1, 546)
	line:SetPoint("LEFT", 205, 10)
	line:SetColorTexture(1, 1, 1, .2)
end