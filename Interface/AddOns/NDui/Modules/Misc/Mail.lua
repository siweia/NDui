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

	local editbox = B.CreateEditBox(list, 120, 25)
	editbox:SetPoint("TOPLEFT", 5, -22)
	local swatch = B.CreateColorSwatch(list, "")
	swatch:SetPoint("LEFT", editbox, "RIGHT", 5, 0)

	local function sortBars()
		local index = 0
		for _, bar in pairs(bars) do
			if bar:IsShown() then
				bar:SetPoint("TOPLEFT", list, 5, -50 - index*22)
				index = index + 1
			end
		end
	end

	local function buttonOnClick(self)
		local text = self.name:GetText() or ""
		SendMailNameEditBox:SetText(text)
	end

	local function deleteOnClick(self)
		NDuiADB["ContactList"][self.__owner.name:GetText()] = nil
		self.__owner:Hide()
		sortBars()
		barIndex = barIndex - 1
	end

	local function createContactBar(text, r, g, b)
		local button = CreateFrame("Button", nil, list)
		button:SetSize(165, 20)
		button.HL = button:CreateTexture(nil, "HIGHLIGHT")
		button.HL:SetAllPoints()
		button.HL:SetColorTexture(1, 1, 1, .25)

		button.name = B.CreateFS(button, 13, text, false, "LEFT", 10, 0)
		button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
		button.name:SetJustifyH("LEFT")
		button.name:SetTextColor(r, g, b)

		button:RegisterForClicks("AnyUp")
		button:SetScript("OnClick", buttonOnClick)

		button.delete = B.CreateButton(button, 20, 20, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		button.delete:SetPoint("LEFT", button, "RIGHT", 5, 0)
		button.delete.__owner = button
		button.delete:SetScript("OnClick", deleteOnClick)

		return button
	end

	local function createBar(text, r, g, b)
		if barIndex < 17 then
			barIndex = barIndex + 1
		end
		for i = 1, barIndex do
			if not bars[i] then
				bars[i] = createContactBar(text, r, g, b)
			end
			if not bars[i]:IsShown() then
				bars[i]:Show()
				bars[i].name:SetText(text)
				bars[i].name:SetTextColor(r, g, b)
				break
			end
		end
	end

	bu:SetScript("OnClick", function()
		B:TogglePanel(list)
	end)

	local add = B.CreateButton(list, 42, 25, ADD, 14)
	add:SetPoint("LEFT", swatch, "RIGHT", 5, 0)
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then return end -- incorrect input
		if not strfind(text, "-") then text = text.."-"..DB.MyRealm end -- complete player realm name

		local r, g, b = swatch.tex:GetVertexColor()
		NDuiADB["ContactList"][text] = r..":"..g..":"..b
		createBar(text, r, g, b)
		sortBars()
		editbox:SetText("")
	end)

	for name, color in pairs(NDuiADB["ContactList"]) do
		if color then
			local r, g, b = strsplit(":", color)
			r, g, b = tonumber(r), tonumber(g), tonumber(b)
			createBar(name, r, g, b)
		end
	end
	sortBars()
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