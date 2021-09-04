local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinPanelSection(frame)
	B.StripTextures(frame)
	B.CreateBDFrame(frame, .25)
	_G[frame:GetName().."Title"]:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 5, 2)
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local styledOptions = false

	VideoOptionsFrame:HookScript("OnShow", function()
		if styledOptions then return end

		B.StripTextures(VideoOptionsFrameCategoryFrame)
		B.StripTextures(VideoOptionsFramePanelContainer)
		B.StripTextures(VideoOptionsFrame.Header)
		VideoOptionsFrame.Header:ClearAllPoints()
		VideoOptionsFrame.Header:SetPoint("TOP", VideoOptionsFrame, 0, 0)

		B.SetBD(VideoOptionsFrame)
		VideoOptionsFrame.Border:Hide()
		B.Reskin(VideoOptionsFrameOkay)
		B.Reskin(VideoOptionsFrameCancel)
		B.Reskin(VideoOptionsFrameDefaults)
		B.Reskin(VideoOptionsFrameApply)

		local line = VideoOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(C.mult, 512)
		line:SetPoint("LEFT", 205, 30)
		line:SetColorTexture(1, 1, 1, .25)

		B.HideBackdrop(Display_) -- isNewPatch
		B.HideBackdrop(Graphics_) -- isNewPatch
		B.HideBackdrop(RaidGraphics_) -- isNewPatch
		GraphicsButton:DisableDrawLayer("BACKGROUND")
		RaidButton:DisableDrawLayer("BACKGROUND")

		reskinPanelSection(AudioOptionsSoundPanelPlayback)
		reskinPanelSection(AudioOptionsSoundPanelHardware)
		reskinPanelSection(AudioOptionsSoundPanelVolume)

		local hline = Display_:CreateTexture(nil, "ARTWORK")
		hline:SetSize(580, C.mult)
		hline:SetPoint("TOPLEFT", GraphicsButton, "BOTTOMLEFT", 14, -4)
		hline:SetColorTexture(1, 1, 1, .2)

		local videoPanels = {
			"Display_",
			"Graphics_",
			"RaidGraphics_",
			"Advanced_",
			"NetworkOptionsPanel",
			"InterfaceOptionsLanguagesPanel",
			"AudioOptionsSoundPanel",
			"AudioOptionsVoicePanel",
		}
		for _, name in pairs(videoPanels) do
			local frame = _G[name]
			if frame then
				for i = 1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:IsObjectType("CheckButton") then
						B.ReskinCheck(child)
					elseif child:IsObjectType("Button") then
						B.Reskin(child)
					elseif child:IsObjectType("Slider") then
						B.ReskinSlider(child)
					elseif child:IsObjectType("Frame") and child.Left and child.Middle and child.Right then
						B.ReskinDropDown(child)
					end
				end
			else
				if DB.isDeveloper then print(name, "not found.") end
			end
		end

		local testInputDevie = AudioOptionsVoicePanelTestInputDevice
		B.Reskin(testInputDevie.ToggleTest)
		B.StripTextures(testInputDevie.VUMeter)
		testInputDevie.VUMeter.Status:SetStatusBarTexture(DB.bdTex)
		local bg = B.CreateBDFrame(testInputDevie.VUMeter, .3)
		bg:SetInside(nil, 4, 4)

		styledOptions = true
	end)

	hooksecurefunc("AudioOptionsVoicePanel_InitializeCommunicationModeUI", function(self)
		if not self.styled then
			B.Reskin(self.PushToTalkKeybindButton)
			self.styled = true
		end
	end)
end)