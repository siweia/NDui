local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	if not AuroraConfig.loot then return end

	LootFramePortraitOverlay:Hide()

	select(19, LootFrame:GetRegions()):SetPoint("TOP", LootFrame, "TOP", 0, -7)

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local ic = _G["LootButton"..index.."IconTexture"]

		if not ic.bg then
			local bu = _G["LootButton"..index]

			_G["LootButton"..index.."IconQuestTexture"]:SetAlpha(0)
			_G["LootButton"..index.."NameFrame"]:Hide()

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")
			bu.IconBorder:SetAlpha(0)

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 114, 0)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bd, .25)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)
		end

		if select(6, GetLootSlotInfo(index)) then
			ic.bg:SetVertexColor(1, 1, 0)
		else
			ic.bg:SetVertexColor(0, 0, 0)
		end
	end)

	LootFrameDownButton:ClearAllPoints()
	LootFrameDownButton:SetPoint("BOTTOMRIGHT", -8, 6)
	LootFramePrev:ClearAllPoints()
	LootFramePrev:SetPoint("LEFT", LootFrameUpButton, "RIGHT", 4, 0)
	LootFrameNext:ClearAllPoints()
	LootFrameNext:SetPoint("RIGHT", LootFrameDownButton, "LEFT", -4, 0)

	F.ReskinPortraitFrame(LootFrame, true)
	F.ReskinArrow(LootFrameUpButton, "up")
	F.ReskinArrow(LootFrameDownButton, "down")

	-- Master looter frame

	for i = 1, 9 do
		select(i, MasterLooterFrame:GetRegions()):Hide()
	end

	MasterLooterFrame.Item.NameBorderLeft:Hide()
	MasterLooterFrame.Item.NameBorderRight:Hide()
	MasterLooterFrame.Item.NameBorderMid:Hide()
	MasterLooterFrame.Item.IconBorder:Hide()
	MasterLooterFrame.Item.Icon:SetTexCoord(.08, .92, .08, .92)
	MasterLooterFrame.Item.Icon:SetDrawLayer("ARTWORK")
	MasterLooterFrame.Item.bg = F.CreateBG(MasterLooterFrame.Item.Icon)

	MasterLooterFrame:HookScript("OnShow", function(self)
		self.Item.bg:SetVertexColor(self.Item.IconBorder:GetVertexColor())
		LootFrame:SetAlpha(.4)
	end)

	MasterLooterFrame:HookScript("OnHide", function(self)
		LootFrame:SetAlpha(1)
	end)

	F.CreateBD(MasterLooterFrame)
	F.ReskinClose(select(3, MasterLooterFrame:GetChildren()))

	hooksecurefunc("MasterLooterFrame_UpdatePlayers", function()
		for i = 1, MAX_RAID_MEMBERS do
			local playerFrame = MasterLooterFrame["player"..i]
			if playerFrame then
				if not playerFrame.styled then
					playerFrame.Bg:SetPoint("TOPLEFT", 1, -1)
					playerFrame.Bg:SetPoint("BOTTOMRIGHT", -1, 1)
					playerFrame.Highlight:SetPoint("TOPLEFT", 1, -1)
					playerFrame.Highlight:SetPoint("BOTTOMRIGHT", -1, 1)
					playerFrame.Highlight:SetTexture(C.media.backdrop)

					F.CreateBD(playerFrame, 0)

					playerFrame.styled = true
				end
				local colour = C.classcolours[select(2, UnitClass(playerFrame.Name:GetText()))]
				playerFrame.Name:SetTextColor(colour.r, colour.g, colour.b)
				playerFrame.Highlight:SetVertexColor(colour.r, colour.g, colour.b, .2)
			else
				break
			end
		end
	end)

	-- Bonus roll

	BonusRollFrame.Background:SetAlpha(0)
	BonusRollFrame.IconBorder:Hide()
	BonusRollFrame.BlackBackgroundHoist.Background:Hide()
	BonusRollFrame.SpecRing:SetAlpha(0)
	BonusRollFrame.SpecIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBDFrame(BonusRollFrame.SpecIcon)

	BonusRollFrame.PromptFrame.Icon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(BonusRollFrame.PromptFrame.Icon)

	BonusRollFrame.PromptFrame.Timer.Bar:SetTexture(C.media.backdrop)

	F.CreateBD(BonusRollFrame)
	F.CreateBDFrame(BonusRollFrame.PromptFrame.Timer, .25)

	-- Loot Roll Frame

	hooksecurefunc("GroupLootFrame_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			if not frame.styled then
				frame.Border:SetAlpha(0)
				frame.Background:SetAlpha(0)
				frame.bg = F.CreateBDFrame(frame)

				frame.Timer.Bar:SetTexture(C.media.backdrop)
				frame.Timer.Bar:SetVertexColor(1, .8, 0)
				frame.Timer.Background:SetAlpha(0)
				F.CreateBDFrame(frame.Timer, .25)

				frame.IconFrame.Border:SetAlpha(0)
				F.ReskinIcon(frame.IconFrame.Icon)

				local bg = F.CreateBDFrame(frame, .25)
				bg:SetPoint("TOPLEFT", frame.IconFrame.Icon, "TOPRIGHT", 0, 1)
				bg:SetPoint("BOTTOMRIGHT", frame.IconFrame.Icon, "BOTTOMRIGHT", 150, -1)

				frame.styled = true
			end

			if frame:IsShown() then
				local _, _, _, quality = GetLootRollItemInfo(frame.rollID)
				local color = BAG_ITEM_QUALITY_COLORS[quality]
				frame.bg:SetBackdropBorderColor(color.r*.6, color.g*.6, color.b*.6)
			end
		end
	end)
end)