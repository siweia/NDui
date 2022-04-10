local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local strfind = strfind
local GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills = GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills
local GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts = GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts

local skinIndex = 0
function S:TradeSkill_OnEvent(addon)
	if addon == "Blizzard_CraftUI" then
		S:EnhancedCraft()
		skinIndex = skinIndex + 1
	elseif addon == "Blizzard_TradeSkillUI" then
		S:EnhancedTradeSkill()
		skinIndex = skinIndex + 1
	end

	if skinIndex >= 2 then
		B:UnregisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
	end
end

function S:TradeSkillSkin()
	if not C.db["Skins"]["TradeSkills"] then return end

	B:RegisterEvent("ADDON_LOADED", S.TradeSkill_OnEvent)
end

local function createArrowButton(parent, anchor, direction)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
	B.ReskinArrow(button, direction)
	if C.db["Skins"]["BlizzardSkins"] then
		button:SetSize(20, 20)
	end

	return button
end

local function removeInputText(self)
	self:SetText("")
end

function S:CreateSearchWidget(parent, anchor)
	local title = B.CreateFS(parent, 15, SEARCH, "system")
	title:ClearAllPoints()

	local searchBox = B.CreateEditBox(parent, 150, 20)
	if C.db["Skins"]["BlizzardSkins"] then
		title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 6, -6)
		searchBox.bg:SetBackdropColor(0, 0, 0, 0)
		searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 3, 3)
		searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, -23)
	else
		title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 5, -5)
		searchBox:SetFrameLevel(6)
		searchBox.bg:SetBackdropColor(0, 0, 0)
		searchBox.bg:SetBackdropBorderColor(1, .8, 0, .5)
		searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 3, 1)
		searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -42, -20)
	end
	searchBox:HookScript("OnEscapePressed", removeInputText)
	searchBox.title = L["Tips"]
	B.AddTooltip(searchBox, "ANCHOR_TOP", L["TradeSearchTip"]..L["EditBox Tip"], "info")

	local nextButton = createArrowButton(searchBox, searchBox, "down")
	local prevButton = createArrowButton(searchBox, nextButton, "up")

	return searchBox, nextButton, prevButton
end

local function updateScrollBarValue(scrollBar, maxSkills, selectSkill)
	local _, maxValue = scrollBar:GetMinMaxValues()
	if maxValue == 0 then return end
	local maxIndex = maxSkills - 22
	if maxIndex <= 0 then return end
	local selectIndex = selectSkill - 22
	if selectIndex < 0 then selectIndex = 0 end

	scrollBar:SetValue(selectIndex / maxIndex * maxValue)
end

function S:UpdateTradeSelection(i, maxSkills)
	TradeSkillFrame_SetSelection(i)
	TradeSkillFrame_Update()
	updateScrollBarValue(TradeSkillListScrollFrameScrollBar, maxSkills, GetTradeSkillSelectionIndex())
end

function S:GetTradeSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetTradeSkillInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			S:UpdateTradeSelection(i, GetNumTradeSkills())
			return true
		end
	end
end

function S:UpdateCraftSelection(i, maxSkills)
	CraftFrame_SetSelection(i)
	CraftFrame_Update()
	updateScrollBarValue(CraftListScrollFrameScrollBar, maxSkills, GetCraftSelectionIndex())
end

function S:GetCraftSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetCraftInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			S:UpdateCraftSelection(i, GetNumCrafts())
			return true
		end
	end
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
	TradeSkillInvSlotDropDown:ClearAllPoints()
	TradeSkillInvSlotDropDown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)

	-- Reskin
	if C.db["Skins"]["BlizzardSkins"] then
		TradeSkillFrame:SetHeight(512)
		TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 78)
		TradeSkillRankFrame:ClearAllPoints()
		TradeSkillRankFrame:SetPoint("TOPLEFT", TradeSkillFrame, 24, -24)
	else
		TradeSkillFrameCloseButton:ClearAllPoints()
		TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -30, -8)
	end

	hooksecurefunc("TradeSkillFrame_Update", function()
		TradeSkillHighlightFrame:SetWidth(300)
	end)

	-- Search widgets
	local searchBox, nextButton, prevButton = S:CreateSearchWidget(TradeSkillFrame, TradeSkillRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() + 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)
end

function S:EnhancedCraft()
	local CraftFrame = _G.CraftFrame
	if CraftFrame:GetWidth() > 700 then return end

	B.StripTextures(CraftFrame)
	CraftFrame.TitleText = CraftFrameTitleText
	CraftFrame.scrollFrame = _G.CraftDetailScrollFrame
	CraftFrame.listScrollFrame = _G.CraftListScrollFrame
	S:EnlargeDefaultUIPanel("CraftFrame", 1)

	_G.CRAFTS_DISPLAYED = 22
	for i = 2, _G.CRAFTS_DISPLAYED do
		local button = _G["Craft"..i]
		if not button then
			button = CreateFrame("Button", "Craft"..i, CraftFrame, "CraftButtonTemplate")
			button:SetID(i)
			button:Hide()
		end
		button:SetPoint("TOPLEFT", _G["Craft"..(i-1)], "BOTTOMLEFT", 0, 1)
	end

	CraftFramePointsLabel:ClearAllPoints()
	CraftFramePointsLabel:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 100, -70)
	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:SetPoint("LEFT", CraftFramePointsLabel, "RIGHT", 3, 0)

	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 54)
	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:SetPoint("RIGHT", CraftCancelButton, "LEFT", -1, 0)

	hooksecurefunc("CraftFrame_Update", function()
		CraftHighlightFrame:SetWidth(300)
	end)

	if C.db["Skins"]["BlizzardSkins"] then
		CraftFrame:SetHeight(512)
		CraftCancelButton:ClearAllPoints()
		CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 78)
		CraftRankFrame:ClearAllPoints()
		CraftRankFrame:SetPoint("TOPLEFT", CraftFrame, 24, -24)
	else
		CraftFrameCloseButton:ClearAllPoints()
		CraftFrameCloseButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -30, -8)
	end

	-- Search widget
	local searchBox, nextButton, prevButton = S:CreateSearchWidget(CraftFrame, CraftRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["InvalidName"])
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, GetCraftSelectionIndex()+1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then return end

		if not S:GetCraftSearchResult(text, GetCraftSelectionIndex()-1, 1, -1) then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["NoMatchReult"])
		end
	end)
end