local _, ns = ...
local B, C, L, DB = unpack(ns)

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
	B.ReskinInput(TradeSkillFrameEditBox)
	TradeSkillFrameBottomLeftTexture:Hide()
	TradeSkillFrameBottomRightTexture:Hide()

	B.StripTextures(TradeSkillRankFrameBorder)
	B.StripTextures(TradeSkillRankFrame)
	TradeSkillRankFrame:SetStatusBarTexture(DB.bdTex)
	TradeSkillRankFrame.SetStatusBarColor = B.Dummy
	TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(.1, .3, .9, 1), CreateColor(.2, .4, 1, 1))
	B.CreateBDFrame(TradeSkillRankFrame, .25)
	TradeSkillRankFrame:SetWidth(220)

	B.ReskinCollapse(TradeSkillCollapseAllButton)
	TradeSkillExpandButtonFrame:DisableDrawLayer("BACKGROUND")
	B.ReskinCheck(TradeSkillFrameAvailableFilterCheckButton)

	hooksecurefunc("TradeSkillFrame_Update", function()
		for i = 1, 22 do
			local bu = _G["TradeSkillSkill"..i]
			if bu and not bu.styled then
				B.ReskinCollapse(bu)
				bu.styled = true
			end
		end
	end)
	B.ReskinDropDown(TradeSkillSubClassDropdown)
	B.ReskinDropDown(TradeSkillInvSlotDropdown)

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
			local quality = select(3, C_Item.GetItemInfo(skillLink))
			if quality and quality > 1 then
				local r, g, b = GetItemQualityColor(quality)
				TradeSkillSkillName:SetTextColor(r, g, b)
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