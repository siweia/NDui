local _, ns = ...
local B, C, L, DB, F = unpack(ns)
local M = B:GetModule("Misc")

local strsplit, pairs, tonumber, sub, strfind = string.split, pairs, tonumber, string.sub, string.find
local deletedelay, mailItemIndex, inboxItems = .5, 0, {}
local button1, button2, button3, lastopened, imOrig_InboxFrame_OnClick, hasNewMail, takingOnlyCash, onlyCurrentMail, needsToWait, skipMail

function M:MailItem_OnClick()
	mailItemIndex = 7 * (InboxFrame.pageNum - 1) + tonumber(sub(self:GetName(), 9, 9))
	local modifiedClick = IsModifiedClick("MAILAUTOLOOTTOGGLE")
	if modifiedClick then
		InboxFrame_OnModifiedClick(self, self.index)
	else
		InboxFrame_OnClick(self, self.index)
	end
end

function M:MailBox_OpenAll()
	if GetInboxNumItems() == 0 then return end

	button1:SetScript("OnClick", nil)
	button2:SetScript("OnClick", nil)
	button3:SetScript("OnClick", nil)
	imOrig_InboxFrame_OnClick = InboxFrame_OnClick
	InboxFrame_OnClick = B.Dummy

	if onlyCurrentMail then
		button3:RegisterEvent("UI_ERROR_MESSAGE")
		M.MailBox_Open(button3, mailItemIndex)
	else
		button1:RegisterEvent("UI_ERROR_MESSAGE")
		M.MailBox_Open(button1, GetInboxNumItems())
	end
end

function M:MailBox_Update(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if (not needsToWait) or (self.elapsed > deletedelay) then
		self.elapsed = 0
		needsToWait = false
		self:SetScript("OnUpdate", nil)

		local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(lastopened)
		if skipMail then
			M.MailBox_Open(self, lastopened - 1)
		elseif money > 0 or (not takingOnlyCash and numItems and numItems > 0 and COD <= 0) then
			M.MailBox_Open(self, lastopened)
		else
			M.MailBox_Open(self, lastopened - 1)
		end
	end
end

function M:MailBox_Open(index)
	if not InboxFrame:IsVisible() or index == 0 then
		M:MailBox_Stop()
		return
	end

	local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
	if not takingOnlyCash then
		if money > 0 or (numItems and numItems > 0) and COD <= 0 then
			AutoLootMailItem(index)
			needsToWait = true
		end
		if onlyCurrentMail then M:MailBox_Stop() return end
	elseif money > 0 then
		TakeInboxMoney(index)
		needsToWait = true
	end

	local items = GetInboxNumItems()
	if (numItems and numItems > 0) or (items > 1 and index <= items) then
		lastopened = index
		self:SetScript("OnUpdate", M.MailBox_Update)
	else
		M:MailBox_Stop()
	end
end

function M:MailBox_Stop()
	button1:SetScript("OnUpdate", nil)
	button1:SetScript("OnClick", function() onlyCurrentMail = false M:MailBox_OpenAll() end)
	button2:SetScript("OnClick", function() takingOnlyCash = true M:MailBox_OpenAll() end)
	button3:SetScript("OnUpdate", nil)
	button3:SetScript("OnClick", function() onlyCurrentMail = true M:MailBox_OpenAll() end)
	if imOrig_InboxFrame_OnClick then
		InboxFrame_OnClick = imOrig_InboxFrame_OnClick
	end
	if onlyCurrentMail then
		button3:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		button1:UnregisterEvent("UI_ERROR_MESSAGE")
	end
	takingOnlyCash = false
	onlyCurrentMail = false
	needsToWait = false
	skipMail = false
end

function M:MailBox_OnEvent(event, _, msg)
	if event == "UI_ERROR_MESSAGE" then
		if msg == ERR_INV_FULL then
			M:MailBox_Stop()
		elseif msg == ERR_ITEM_MAX_COUNT then
			skipMail = true
		end
	elseif event == "MAIL_CLOSED" then
		if not hasNewMail then MiniMapMailFrame:Hide() end
		M:MailBox_Stop()
	end
end

function M:TotalCash_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local total_cash = 0
	for index = 0, GetInboxNumItems() do
		total_cash = total_cash + select(5, GetInboxHeaderInfo(index))
	end
	if total_cash > 0 then SetTooltipMoney(GameTooltip, total_cash)	end
	GameTooltip:Show()
end

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

function M:CreatButton(parent, text, w, h, ap, frame, rp, x, y)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetWidth(w)
	button:SetHeight(h)
	button:SetPoint(ap, frame, rp, x, y)
	button:SetText(text)
	return button
end

function M:InboxFrame_Hook()
	hasNewMail = false
	if select(4, GetInboxHeaderInfo(1)) then
		for i = 1, GetInboxNumItems() do
			local wasRead = select(9, GetInboxHeaderInfo(i))
			if not wasRead then
				hasNewMail = true
				break
			end
		end
	end
end

function M:InboxItem_OnEnter()
	wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, 12 do
			local _, _, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				local _, itemid = strsplit(":", GetInboxItemLink(self.index, attachID))
				itemid = tonumber(itemid)
				inboxItems[itemid] = (inboxItems[itemid] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine(L["Attach List"])
			for key, value in pairs(inboxItems) do
				local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(key)
				if itemName then
					local r, g, b = GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T"..itemTexture..":12:12:0:0:50:50:4:46:4:46|t "..itemName, value, r, g, b)
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
	list:SetPoint("TOPLEFT", MailFrame, "TOPRIGHT", 5, 0)
	list:SetFrameStrata("Tooltip")
	B.SetBackground(list)
	B.CreateFS(list, 14, L["ContactList"], "system", "TOP", 0, -5)
	list:Hide()

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
		ToggleFrame(list)
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

	for i = 1, 7 do
		local itemButton = _G["MailItem"..i.."Button"]
		itemButton:SetScript("OnClick", M.MailItem_OnClick)
		M.MailItem_AddDelete(itemButton, i)
	end

	button1 = M:CreatButton(InboxFrame, L["Collect All"], 100, 22, "TOPLEFT", "InboxFrame", "TOPLEFT", 50, -35)
	button1:RegisterEvent("MAIL_CLOSED")
	button1:SetScript("OnClick", M.MailBox_OpenAll)
	button1:SetScript("OnEvent", M.MailBox_OnEvent)

	button2 = M:CreatButton(InboxFrame, L["Collect Gold"], 100, 22, "LEFT", button1, "RIGHT", 30, 0)
	button2:SetScript("OnClick", function()
		takingOnlyCash = true
		M:MailBox_OpenAll()
	end)
	button2:SetScript("OnEnter", M.TotalCash_OnEnter)
	button2:SetScript("OnLeave", B.HideTooltip)

	button3 = M:CreatButton(OpenMailFrame, L["Collect Letters"], 82, 22, "RIGHT", "OpenMailReplyButton", "LEFT", 0, 0)
	button3:SetScript("OnClick", function()
		onlyCurrentMail = true
		M:MailBox_OpenAll()
	end)
	button3:SetScript("OnEvent", M.MailBox_OnEvent)

	hooksecurefunc("InboxFrame_Update", M.InboxFrame_Hook)
	hooksecurefunc("InboxFrameItem_OnEnter", M.InboxItem_OnEnter)

	M:MailBox_ContactList()

	-- Replace the alert frame
	if InboxTooMuchMail then
		InboxTooMuchMail:ClearAllPoints()
		InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)
	end

	-- Aurora Reskin
	if F then
		F.Reskin(button1)
		F.Reskin(button2)
		F.Reskin(button3)
	end

	-- Hide Blizz
	B.HideObject(OpenAllMail)
end