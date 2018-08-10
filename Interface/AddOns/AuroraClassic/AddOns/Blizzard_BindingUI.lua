local F, C = unpack(select(2, ...))

C.themes["Blizzard_BindingUI"] = function()
	local r, g, b = C.r, C.g, C.b

	local KeyBindingFrame = KeyBindingFrame

	KeyBindingFrame.header:DisableDrawLayer("BACKGROUND")
	KeyBindingFrame.header:DisableDrawLayer("BORDER")
	KeyBindingFrame.scrollFrame.scrollBorderTop:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderBottom:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollBorderMiddle:SetTexture("")
	KeyBindingFrame.scrollFrame.scrollFrameScrollBarBackground:SetTexture("")
	KeyBindingFrame.categoryList:DisableDrawLayer("BACKGROUND")
	KeyBindingFrame.bindingsContainer:SetBackdrop(nil)

	F.CreateBD(KeyBindingFrame)
	F.CreateSD(KeyBindingFrame)
	F.Reskin(KeyBindingFrame.defaultsButton)
	F.Reskin(KeyBindingFrame.unbindButton)
	F.Reskin(KeyBindingFrame.okayButton)
	F.Reskin(KeyBindingFrame.cancelButton)
	F.ReskinCheck(KeyBindingFrame.characterSpecificButton)
	F.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)
	KeyBindingFrameScrollFrame.scrollFrameScrollBarBackground:Hide()

	for i = 1, KEY_BINDINGS_DISPLAYED do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
	end

	hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(_, button)
		if not button.styled then
			local selected = button.selectedHighlight
			selected:SetTexture(C.media.backdrop)
			selected:SetPoint("TOPLEFT", 1, -1)
			selected:SetPoint("BOTTOMRIGHT", -1, 1)
			selected:SetColorTexture(r, g, b, .25)
			F.Reskin(button)

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