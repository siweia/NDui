local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
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
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			bu.IconBorder:SetAlpha(0)

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 114, 0)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bd, .25)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)
		end

		if select(7, GetLootSlotInfo(index)) then
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

	-- Bonus roll

	do
		local frame = BonusRollFrame

		frame.Background:SetAlpha(0)
		frame.IconBorder:Hide()
		frame.BlackBackgroundHoist.Background:Hide()
		frame.SpecRing:SetAlpha(0)
		frame.SpecIcon:SetTexCoord(.08, .92, .08, .92)
		local bg = F.CreateBDFrame(frame.SpecIcon)
		hooksecurefunc("BonusRollFrame_StartBonusRoll", function()
			bg:SetShown(frame.SpecIcon:IsShown())
		end)

		F.ReskinIcon(frame.PromptFrame.Icon)
		frame.PromptFrame.Timer.Bar:SetTexture(C.media.backdrop)
		F.CreateBD(frame)
		F.CreateSD(frame)
		if frame.Shadow then
			frame.Shadow:SetFrameLevel(bg:GetFrameLevel() - 1)
		end
		F.CreateBDFrame(frame.PromptFrame.Timer, .25)

		local from, to = "|T.+|t", "|T%%s:14:14:0:0:64:64:5:59:5:59|t"
		BONUS_ROLL_COST = BONUS_ROLL_COST:gsub(from, to)
		BONUS_ROLL_CURRENT_COUNT = BONUS_ROLL_CURRENT_COUNT:gsub(from, to)
	end

	-- Loot Roll Frame

	hooksecurefunc("GroupLootFrame_OpenNewFrame", function()
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			if not frame.styled then
				frame.Border:SetAlpha(0)
				frame.Background:SetAlpha(0)
				frame.bg = F.CreateBDFrame(frame)
				F.CreateSD(frame)

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
				frame.bg:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		end
	end)
end)