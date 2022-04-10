local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_CraftUI"] = function()
	B.ReskinPortraitFrame(CraftFrame, 10, -10, -30, 70)
	B.ReskinScroll(CraftListScrollFrameScrollBar)
	B.ReskinScroll(CraftDetailScrollFrameScrollBar)
	B.Reskin(CraftCreateButton)
	B.Reskin(CraftCancelButton)

	B.StripTextures(CraftRankFrameBorder)
	B.StripTextures(CraftRankFrame)
	CraftRankFrame:SetStatusBarTexture(DB.bdTex)
	CraftRankFrame.SetStatusBarColor = B.Dummy
	CraftRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	B.CreateBDFrame(CraftRankFrame, .25)
	CraftRankFrame:SetWidth(220)

	B.StripTextures(CraftDetailScrollChildFrame)
	B.StripTextures(CraftIcon)
	B.CreateBDFrame(CraftIcon)
	B.ReskinCollapse(CraftCollapseAllButton)
	CraftExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	hooksecurefunc("CraftFrame_SetSelection", function(id)
		if not id then return end
		local tex = CraftIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end
	end)

	for i = 1, MAX_CRAFT_REAGENTS do
		local icon = _G["CraftReagent"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(icon)

		local nameFrame = _G["CraftReagent"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = B.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end

	--B.ReskinDropDown(CraftFrameFilterDropDown)
	--B.ReskinCheck(CraftFrameAvailableFilterCheckButton)
end

C.themes["Blizzard_TradeSkillUI"] = function()
	B.ReskinPortraitFrame(TradeSkillFrame, 10, -10, -30, 70)
	B.ReskinScroll(TradeSkillListScrollFrameScrollBar)
	B.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
	B.Reskin(TradeSkillCreateAllButton)
	B.Reskin(TradeSkillCreateButton)
	B.Reskin(TradeSkillCancelButton)
	B.ReskinArrow(TradeSkillDecrementButton, "left")
	B.ReskinArrow(TradeSkillIncrementButton, "right")
	B.ReskinInput(TradeSkillInputBox)

	B.StripTextures(TradeSkillRankFrameBorder)
	B.StripTextures(TradeSkillRankFrame)
	TradeSkillRankFrame:SetStatusBarTexture(DB.bdTex)
	TradeSkillRankFrame.SetStatusBarColor = B.Dummy
	TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
	B.CreateBDFrame(TradeSkillRankFrame, .25)
	TradeSkillRankFrame:SetWidth(220)

	B.ReskinCollapse(TradeSkillCollapseAllButton)
	TradeSkillExpandButtonFrame:DisableDrawLayer("BACKGROUND")

	TradeSkillFrame:HookScript("OnShow", function()
		for i = 1, 22 do
			local bu = _G["TradeSkillSkill"..i]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu.styled = true
			end
		end
	end)

	B.ReskinDropDown(TradeSkillSubClassDropDown)
	B.ReskinDropDown(TradeSkillInvSlotDropDown)

	B.StripTextures(TradeSkillDetailScrollChildFrame)
	B.StripTextures(TradeSkillSkillIcon)
	B.CreateBDFrame(TradeSkillSkillIcon)

	hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
		local skillType = select(2, GetTradeSkillInfo(id))
		if skillType == "header" then return end

		local tex = TradeSkillSkillIcon:GetNormalTexture()
		if tex then
			tex:SetTexCoord(.08, .92, .08, .92)
		end

		local skillLink = GetTradeSkillItemLink(id)
		if skillLink then
			local quality = select(3, GetItemInfo(skillLink))
			if quality and quality > 1 then
				TradeSkillSkillName:SetTextColor(GetItemQualityColor(quality))
			else
				TradeSkillSkillName:SetTextColor(1, 1, 1)
			end
		end
	end)

	for i = 1, MAX_TRADE_SKILL_REAGENTS do
		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
		icon:SetTexCoord(.08, .92, .08, .92)
		B.CreateBDFrame(icon)

		local nameFrame = _G["TradeSkillReagent"..i.."NameFrame"]
		nameFrame:Hide()
		local bg = B.CreateBDFrame(nameFrame, .25)
		bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, C.mult)
		bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 100, -C.mult)
	end
end