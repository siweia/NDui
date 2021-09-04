local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_BindingUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	local KeyBindingFrame = KeyBindingFrame

	B.StripTextures(KeyBindingFrame.Header)
	B.StripTextures(KeyBindingFrame.categoryList)
	B.HideBackdrop(KeyBindingFrame.bindingsContainer) -- isNewPatch

	B.StripTextures(KeyBindingFrame)
	B.SetBD(KeyBindingFrame)
	B.Reskin(KeyBindingFrame.defaultsButton)
	B.Reskin(KeyBindingFrame.quickKeybindButton)
	B.Reskin(KeyBindingFrame.unbindButton)
	B.Reskin(KeyBindingFrame.okayButton)
	B.Reskin(KeyBindingFrame.cancelButton)
	B.ReskinCheck(KeyBindingFrame.characterSpecificButton)
	B.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)

	for i = 1, KEY_BINDINGS_DISPLAYED do
		local button1 = _G["KeyBindingFrameKeyBinding"..i.."Key1Button"]
		local button2 = _G["KeyBindingFrameKeyBinding"..i.."Key2Button"]
		button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
	end

	hooksecurefunc("BindingButtonTemplate_SetupBindingButton", function(_, button)
		if not button.styled then
			local selected = button.selectedHighlight
			selected:SetTexture(DB.bdTex)
			selected:SetInside()
			selected:SetColorTexture(r, g, b, .25)
			B.Reskin(button)

			button.styled = true
		end
	end)

	local line = KeyBindingFrame:CreateTexture(nil, "ARTWORK")
	line:SetSize(C.mult, 546)
	line:SetPoint("LEFT", 205, 10)
	line:SetColorTexture(1, 1, 1, .25)

	-- QuickKeybindFrame

	local frame = QuickKeybindFrame
	B.StripTextures(frame)
	B.StripTextures(frame.Header)
	B.SetBD(frame)
	B.ReskinCheck(frame.characterSpecificButton)
	frame.characterSpecificButton:SetSize(24, 24)
	B.Reskin(frame.okayButton)
	B.Reskin(frame.defaultsButton)
	B.Reskin(frame.cancelButton)
end