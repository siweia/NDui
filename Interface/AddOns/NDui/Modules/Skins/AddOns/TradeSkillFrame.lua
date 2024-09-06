local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

function S:TradeSkill_OnEvent(addon)
	if addon == "Blizzard_TradeSkillUI" then
		S:EnhancedTradeSkill()
		B:UnregisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
	end
end

function S:TradeSkillSkin()
	if not C.db["Skins"]["TradeSkills"] then return end

	B:RegisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
end

function S:EnhancedTradeSkill()
	local TradeSkillFrame = _G.TradeSkillFrame
	if TradeSkillFrame:GetWidth() > 700 then return end

	B.StripTextures(TradeSkillFrame)
	TradeSkillFrame.TitleText = TradeSkillFrameTitleText
	TradeSkillFrame.scrollFrame = _G.TradeSkillDetailScrollFrame
	TradeSkillFrame.listScrollFrame = _G.TradeSkillListScrollFrame
	S:EnlargeDefaultUIPanel("TradeSkillFrame", 1)

	_G.TRADE_SKILLS_DISPLAYED = 22
	for i = 2, _G.TRADE_SKILLS_DISPLAYED do
		local button = _G["TradeSkillSkill"..i]
		if not button then
			button = CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
			button:SetID(i)
			button:Hide()
		end
		button:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i-1)], "BOTTOMLEFT", 0, 1)
	end

	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 54)
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", -1, 0)
	if DB.isNewPatch then
		TradeSkillInvSlotDropdown:ClearAllPoints()
		TradeSkillInvSlotDropdown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)
	else
		TradeSkillInvSlotDropDown:ClearAllPoints()
		TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)
	end
	TradeSkillFrameAvailableFilterCheckButton:SetPoint("TOPLEFT", 230, -70)

	if C.db["Skins"]["BlizzardSkins"] then
		TradeSkillFrame:SetHeight(512)
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 78)
	else
		TradeSkillFrameBottomLeftTexture:Hide()
		TradeSkillFrameBottomRightTexture:Hide()
		TradeSkillFrameCloseButton:ClearAllPoints()
		TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -30, -8)
	end
end