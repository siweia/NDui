local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:GetModule("Misc")

local wipe, select, pairs, tonumber = wipe, select, pairs, tonumber
local strsplit, strfind = strsplit, strfind
local InboxItemCanDelete, DeleteInboxItem = InboxItemCanDelete, DeleteInboxItem
local GetInboxHeaderInfo, GetInboxItem, GetItemInfo = GetInboxHeaderInfo, GetInboxItem, GetItemInfo
local inboxItems = {}

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

function M:ContactButton_OnClick()
	local text = self.name:GetText() or ""
	SendMailNameEditBox:SetText(text)
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

function M:ContactList_Refresh()
	wipe(contactList)

	local count = 0
	for name, color in pairs(NDuiADB["ContactList"]) do
		count = count + 1
		local r, g, b = strsplit(":", color)
		if not contactList[count] then contactList[count] = {} end
		contactList[count].name = name
		contactList[count].r = r
		contactList[count].g = g
		contactList[count].b = b
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
	local bars = {}
	local barIndex = 0

	local bu = B.CreateGear(SendMailFrame)
	bu:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 3, 0)

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
	editbox.title = L["Tips"]
	B.AddTooltip(editbox, "ANCHOR_BOTTOMRIGHT", DB.InfoColor..L["AddContactTip"])
	local swatch = B.CreateColorSwatch(list, "")
	swatch:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
	local add = B.CreateButton(list, 42, 22, ADD, 14)
	add:SetPoint("LEFT", swatch, "RIGHT", 5, 0)
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then return end -- incorrect input
		if not strfind(text, "-") then text = text.."-"..DB.MyRealm end -- complete player realm name
		if NDuiADB["ContactList"][text] then return end -- unit exists

		local r, g, b = swatch.tex:GetVertexColor()
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

function M:MailBox()
	if not NDuiDB["Misc"]["Mail"] then return end
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

	-- Replace the alert frame
	if InboxTooMuchMail then
		InboxTooMuchMail:ClearAllPoints()
		InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)
	end
end
M:RegisterMisc("MailBox", M.MailBox)