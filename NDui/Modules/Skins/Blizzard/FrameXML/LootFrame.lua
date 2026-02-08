local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["Loot"] then return end

	LootFramePortraitOverlay:Hide()

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local name = "LootButton"..index
		local bu = _G[name]
		if not bu:IsShown() then return end

		local nameFrame = _G[name.."NameFrame"]
		--local questTexture = _G[name.."IconQuestTexture"]

		if not bu.bg then
			nameFrame:Hide()
			--questTexture:SetAlpha(0)
			bu:SetNormalTexture(0)
			bu:SetPushedTexture(0)
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			bu.IconBorder:SetAlpha(0)
			bu.bg = B.ReskinIcon(bu.icon)

			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 1, 0)
			bg:SetPoint("BOTTOMRIGHT", bu.bg, 115, 0)
		end

		if select(7, GetLootSlotInfo(index)) then -- questTexture:IsShown()
			bu.bg:SetBackdropBorderColor(.8, .8, 0)
		else
			bu.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	LootFrameDownButton:ClearAllPoints()
	LootFrameDownButton:SetPoint("BOTTOMRIGHT", -8, 6)
	LootFramePrev:ClearAllPoints()
	LootFramePrev:SetPoint("LEFT", LootFrameUpButton, "RIGHT", 4, 0)
	LootFrameNext:ClearAllPoints()
	LootFrameNext:SetPoint("RIGHT", LootFrameDownButton, "LEFT", -4, 0)

	B.ReskinPortraitFrame(LootFrame)
	B.ReskinArrow(LootFrameUpButton, "up")
	B.ReskinArrow(LootFrameDownButton, "down")

	-- Master looter frame

	local MasterLooterFrame = MasterLooterFrame

	B.StripTextures(MasterLooterFrame)
	B.StripTextures(MasterLooterFrame.Item)
	MasterLooterFrame.Item.Icon:SetTexCoord(.08, .92, .08, .92)
	MasterLooterFrame.Item.bg = B.CreateBDFrame(MasterLooterFrame.Item.Icon)

	MasterLooterFrame:HookScript("OnShow", function(self)
		local color = DB.QualityColors[LootFrame.selectedQuality or 1]
		self.Item.bg:SetBackdropBorderColor(color.r, color.g, color.b)
		LootFrame:SetAlpha(.4)
	end)

	MasterLooterFrame:HookScript("OnHide", function()
		LootFrame:SetAlpha(1)
	end)

	B.ReskinClose(select(4, MasterLooterFrame:GetChildren()), nil)
	B.SetBD(MasterLooterFrame)

	hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
		for i = 1, MAX_RAID_MEMBERS do
			local playerFrame = MasterLooterFrame["player"..i]
			if playerFrame then
				if not playerFrame.styled then
					playerFrame.Bg:Hide()
					local bg = B.CreateBDFrame(playerFrame, .25)
					playerFrame.Highlight:SetPoint("TOPLEFT", bg, C.mult, -C.mult)
					playerFrame.Highlight:SetPoint("BOTTOMRIGHT", bg, -C.mult, C.mult)
					playerFrame.Highlight:SetColorTexture(1, 1, 1, .25)

					playerFrame.styled = true
				end
			else
				break
			end
		end
	end)

	-- Loot Roll Frame
	--/run GroupLootFrame_OpenNewFrame(1,30) GroupLootFrame1.Hide=GroupLootFrame1.Show GroupLootFrame1:Show()
	hooksecurefunc("GroupLootFrame_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			B.StripTextures(frame)
			if not frame.styled then
				frame.bg = B.SetBD(frame)
				frame.bg:SetInside(frame, 8, 8)
				B.ReskinClose(frame.PassButton, frame.bg, -5, -5)

				B.StripTextures(frame.Timer)
				frame.Timer.Bar:SetTexture(DB.bdTex)
				frame.Timer.Bar:SetVertexColor(1, .8, 0)
				frame.Timer.Background:SetAlpha(0)
				B.CreateBDFrame(frame.Timer, .25)

				local icon = frame.IconFrame.Icon
				icon:ClearAllPoints()
				icon:SetPoint("BOTTOMLEFT", frame.Timer, "TOPLEFT", 0, 5)
				icon.bg = B.ReskinIcon(icon)

				local bg = B.CreateBDFrame(frame, .25)
				bg:SetPoint("TOPLEFT", icon.bg, "TOPRIGHT", 2, 0)
				bg:SetPoint("BOTTOMRIGHT", icon.bg, "BOTTOMRIGHT", 118, 0)

				frame.styled = true
			end

			if frame:IsShown() then
				local quality = select(4, GetLootRollItemInfo(frame.rollID))
				local color = DB.QualityColors[quality or 1]
				frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end)
end)