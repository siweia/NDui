local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local wipe, select, pairs, tonumber = wipe, select, pairs, tonumber
local strsplit, strfind, tinsert = strsplit, strfind, tinsert
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo = GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo
local GetSendMailPrice, GetMoney = GetSendMailPrice, GetMoney
local C_Timer_After = C_Timer.After
local C_Mail_HasInboxMoney = C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = C_Mail.IsCommandPending
local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR
local NORMAL_STRING = GUILDCONTROL_OPTION16
local OPENING_STRING = OPEN_ALL_MAIL_BUTTON_OPENING

local mailIndex, timeToWait, totalCash, inboxItems = 0, .15, 0, {}
local isGoldCollecting

function M:MailBox_DelectClick()
	local selectedID = self.id + (InboxFrame.pageNum-1)*7
	if InboxItemCanDelete(selectedID) then
		DeleteInboxItem(selectedID)
	else
		UIErrorsFrame:AddMessage(DB.InfoColor..ERR_MAIL_DELETE_ITEM_ERROR)
	end
end

function M:MailItem_AddDelete(i)
	local bu = CreateFrame("Button", nil, self)
	bu:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -10, 5)
	bu:SetSize(16, 16)
	B.PixelIcon(bu, 136813, true)
	bu.id = i
	bu:SetScript("OnClick", M.MailBox_DelectClick)
	B.AddTooltip(bu, "ANCHOR_RIGHT", DELETE, "system")
end

function M:InboxItem_OnEnter()
	wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, 12 do
			local _, itemID, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				inboxItems[itemID] = (inboxItems[itemID] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine(L["Attach List"])
			for itemID, count in pairs(inboxItems) do
				local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
				if itemName then
					local r, g, b = GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T"..itemTexture..":12:12:0:0:50:50:4:46:4:46|t "..itemName, count, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
end

local contactList = {}
local contactListByRealm = {}

function M:ContactButton_OnClick()
	local text = self.name:GetText() or ""
	SendMailNameEditBox:SetText(text)
	SendMailNameEditBox:SetCursorPosition(0)
end

function M:ContactButton_Delete()
	NDuiADB["ContactList"][self.__owner.name:GetText()] = nil
	M:ContactList_Refresh()
end

function M:ContactButton_Create(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(150, 20)
	button:SetPoint("TOPLEFT", 2, -2 - (index-1) *20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(1, 1, 1, .25)

	button.name = B.CreateFS(button, 13, "Name", false, "LEFT", 0, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 155, 0)
	button.name:SetJustifyH("LEFT")

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", M.ContactButton_OnClick)

	button.delete = B.CreateButton(button, 20, 20, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	button.delete:SetPoint("LEFT", button, "RIGHT", 2, 0)
	button.delete.__owner = button
	button.delete:SetScript("OnClick", M.ContactButton_Delete)

	return button
end

local function GenerateDataByRealm(realm)
	if contactListByRealm[realm] then
		for name, color in pairs(contactListByRealm[realm]) do
			local r, g, b = strsplit(":", color)
			tinsert(contactList, {name = name.."-"..realm, r = r, g = g, b = b})
		end
	end
end

function M:ContactList_Refresh()
	wipe(contactList)
	wipe(contactListByRealm)

	for fullname, color in pairs(NDuiADB["ContactList"]) do
		local name, realm = strsplit("-", fullname)
		if realm then
			if not contactListByRealm[realm] then contactListByRealm[realm] = {} end
			contactListByRealm[realm][name] = color
		end
	end

	GenerateDataByRealm(DB.MyRealm)

	for realm in pairs(contactListByRealm) do
		if realm ~= DB.MyRealm then
			GenerateDataByRealm(realm)
		end
	end

	M:ContactList_Update()
end

function M:ContactButton_Update(button)
	local index = button.index
	local info = contactList[index]

	button.name:SetText(info.name)
	button.name:SetTextColor(info.r, info.g, info.b)
end

function M:ContactList_Update()
	local scrollFrame = _G.NDuiMailBoxScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = #contactList
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numFriendButtons then
			button.index = index
			M:ContactButton_Update(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numFriendButtons*height, usedHeight)
end

function M:ContactList_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta*self.buttonHeight
	if IsShiftKeyDown() then
		step = step*18
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	M:ContactList_Update()
end

function M:MailBox_ContactList()
	local bu = B.CreateGear(SendMailFrame)
	bu:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 20, 0)

	local list = CreateFrame("Frame", nil, bu)
	list:SetSize(200, 424)
	list:SetPoint("TOPLEFT", MailFrame, "TOPRIGHT", 3, 0)
	list:SetFrameStrata("Tooltip")
	B.SetBD(list)
	B.CreateFS(list, 14, L["ContactList"], "system", "TOP", 0, -5)

	bu:SetScript("OnClick", function()
		B:TogglePanel(list)
	end)

	local editbox = B.CreateEditBox(list, 120, 20)
	editbox:SetPoint("TOPLEFT", 5, -25)
	B.AddTooltip(editbox, "ANCHOR_BOTTOMRIGHT", L["AddContactTip"], "info", true)
	local swatch = B.CreateColorSwatch(list, "")
	swatch:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
	local add = B.CreateButton(list, 42, 22, ADD, 14)
	add:SetPoint("LEFT", swatch, "RIGHT", 5, 0)
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then return end -- incorrect input
		if not strfind(text, "-") then text = text.."-"..DB.MyRealm end -- complete player realm name
		if NDuiADB["ContactList"][text] then return end -- unit exists

		local r, g, b = swatch.tex:GetColor()
		NDuiADB["ContactList"][text] = r..":"..g..":"..b
		M:ContactList_Refresh()
		editbox:SetText("")
	end)

	local scrollFrame = CreateFrame("ScrollFrame", "NDuiMailBoxScrollFrame", list, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(175, 370)
	scrollFrame:SetPoint("BOTTOMLEFT", 5, 5)
	B.CreateBDFrame(scrollFrame, .25)
	list.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	B.ReskinScroll(scrollBar)
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 19 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = M:ContactButton_Create(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = M.ContactList_Update
	scrollFrame:SetScript("OnMouseWheel", M.ContactList_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)

	M:ContactList_Refresh()
end

function M:MailBox_CollectGold()
	if mailIndex > 0 then
		if not C_Mail_IsCommandPending() then
			if C_Mail_HasInboxMoney(mailIndex) then
				TakeInboxMoney(mailIndex)
			end
			mailIndex = mailIndex - 1
		end
		C_Timer_After(timeToWait, M.MailBox_CollectGold)
	else
		isGoldCollecting = false
		M:UpdateOpeningText()
	end
end

function M:MailBox_CollectAllGold()
	if isGoldCollecting then return end
	if totalCash == 0 then return end

	isGoldCollecting = true
	mailIndex = GetInboxNumItems()
	M:UpdateOpeningText(true)
	M:MailBox_CollectGold()
end

function M:TotalCash_OnEnter()
	local numItems = GetInboxNumItems()
	if numItems == 0 then return end

	for i = 1, numItems do
		totalCash = totalCash + select(5, GetInboxHeaderInfo(i))
	end

	if totalCash > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["TotalGold"])
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(M:GetMoneyString(totalCash, true), 1,1,1)
		GameTooltip:Show()
	end
end

function M:TotalCash_OnLeave()
	B:HideTooltip()
	totalCash = 0
end

function M:UpdateOpeningText(opening)
	if opening then
		M.GoldButton:SetText(OPENING_STRING)
	else
		M.GoldButton:SetText(NORMAL_STRING)
	end
end

function M:MailBox_CreatButton(parent, width, height, text, anchor)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetPoint(unpack(anchor))
	button:SetText(text)
	if C.db["Skins"]["BlizzardSkins"] then B.Reskin(button) end

	return button
end

function M:CollectGoldButton()
	OpenAllMail:ClearAllPoints()
	OpenAllMail:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 50, -35)

	local button = M:MailBox_CreatButton(InboxFrame, 120, 24, "", {"LEFT", OpenAllMail, "RIGHT", 3, 0})
	button:SetScript("OnClick", M.MailBox_CollectAllGold)
	button:HookScript("OnEnter", M.TotalCash_OnEnter)
	button:HookScript("OnLeave", M.TotalCash_OnLeave)

	M.GoldButton = button
	M:UpdateOpeningText()
end

function M:MailBox_CollectAttachment()
	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = OpenMailFrame.OpenMailAttachments[i]
		if attachmentButton:IsShown() then
			TakeInboxItem(InboxFrame.openMailID, i)
			C_Timer_After(timeToWait, M.MailBox_CollectAttachment)
			return
		end
	end
end

function M:MailBox_CollectCurrent()
	if OpenMailFrame.cod then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["MailIsCOD"])
		return
	end

	local currentID = InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentID) then
		TakeInboxMoney(currentID)
	end
	M:MailBox_CollectAttachment()
end

function M:CollectCurrentButton()
	local button = M:MailBox_CreatButton(OpenMailFrame, 82, 22, L["TakeAll"], {"RIGHT", "OpenMailReplyButton", "LEFT", -1, 0})
	button:SetScript("OnClick", M.MailBox_CollectCurrent)
end

function M:LastMailSaver()
	local mailSaver = CreateFrame("CheckButton", nil, SendMailFrame, "OptionsBaseCheckButtonTemplate")
	mailSaver:SetHitRectInsets(0, 0, 0, 0)
	mailSaver:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 0, 0)
	mailSaver:SetSize(24, 24)
	B.ReskinCheck(mailSaver)
	mailSaver.bg:SetBackdropBorderColor(1, .8, 0, .5)

	mailSaver:SetChecked(C.db["Misc"]["MailSaver"])
	mailSaver:SetScript("OnClick", function(self)
		C.db["Misc"]["MailSaver"] = self:GetChecked()
	end)
	B.AddTooltip(mailSaver, "ANCHOR_TOP", L["SaveMailTarget"])

	local resetPending
	hooksecurefunc("SendMailFrame_SendMail", function()
		if C.db["Misc"]["MailSaver"] then
			C.db["Misc"]["MailTarget"] = SendMailNameEditBox:GetText()
			resetPending = true
		else
			resetPending = nil
		end
	end)

	hooksecurefunc(SendMailNameEditBox, "SetText", function(self, text)
		if resetPending and text == "" then
			resetPending = nil
			self:SetText(C.db["Misc"]["MailTarget"])
		end
	end)

	SendMailFrame:HookScript("OnShow", function()
		if C.db["Misc"]["MailSaver"] then
			SendMailNameEditBox:SetText(C.db["Misc"]["MailTarget"])
		end
	end)
end

function M:ArrangeDefaultElements()
	InboxTooMuchMail:ClearAllPoints()
	InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)

	SendMailNameEditBox:SetWidth(155)
	SendMailNameEditBoxMiddle:SetWidth(146)
	SendMailCostMoneyFrame:SetAlpha(0)

	SendMailMailButton:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		local sendPrice = GetSendMailPrice()
		local colorStr = "|cffffffff"
		if sendPrice > GetMoney() then colorStr = "|cffff0000" end
		GameTooltip:AddLine(SEND_MAIL_COST..colorStr..M:GetMoneyString(sendPrice, true))
		GameTooltip:Show()
	end)
	SendMailMailButton:HookScript("OnLeave", B.HideTooltip)
end

function M:MailBox()
	if not C.db["Misc"]["Mail"] then return end
	if IsAddOnLoaded("Postal") then return end

	-- Delete buttons
	for i = 1, 7 do
		local itemButton = _G["MailItem"..i.."Button"]
		M.MailItem_AddDelete(itemButton, i)
	end

	-- Tooltips for multi-items
	hooksecurefunc("InboxFrameItem_OnEnter", M.InboxItem_OnEnter)

	-- Custom contact list
	M:MailBox_ContactList()

	-- Elements
	M:ArrangeDefaultElements()
	M.GetMoneyString = B:GetModule("Infobar").GetMoneyString
	M:CollectGoldButton()
	M:CollectCurrentButton()
	M:LastMailSaver()
end
M:RegisterMisc("MailBox", M.MailBox)

-- Temp fix for GM mails
function OpenAllMail:AdvanceToNextItem()
	local foundAttachment = false
	while ( not foundAttachment ) do
		local _, _, _, _, _, CODAmount, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
		local itemID = select(2, GetInboxItem(self.mailIndex, self.attachmentIndex))
		local hasBlacklistedItem = self:IsItemBlacklisted(itemID)
		local hasCOD = CODAmount and CODAmount > 0
		local hasMoneyOrItem = C_Mail.HasInboxMoney(self.mailIndex) or HasInboxItem(self.mailIndex, self.attachmentIndex)
		if ( not hasBlacklistedItem and not isGM and not hasCOD and hasMoneyOrItem ) then
			foundAttachment = true
		else
			self.attachmentIndex = self.attachmentIndex - 1
			if ( self.attachmentIndex == 0 ) then
				break
			end
		end
	end
	
	if ( not foundAttachment ) then
		self.mailIndex = self.mailIndex + 1
		self.attachmentIndex = ATTACHMENTS_MAX
		if ( self.mailIndex > GetInboxNumItems() ) then
			return false
		end
		
		return self:AdvanceToNextItem()
	end
	
	return true
end