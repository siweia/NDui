local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Misc")

--[[
	一个简易的邮箱插件，修改自OpenAll
]]
function module:Mailbox()
	if not NDuiDB["Misc"]["Mail"] then return end

	local deletedelay, t, mailIndex, mailItemIndex, inboxItems = .5, 0, 1, 0, {}
	local button1, button2, button3, button4, lastopened, imOrig_InboxFrame_OnClick, hasNewMail, takingOnlyCash, onlyCurrentMail, needsToWait, skipMail, OpenMail, StopOpening

	InboxNextPageButton:SetScript("OnClick", function()
		mailIndex = mailIndex + 1
		InboxNextPage()
	end)
	InboxPrevPageButton:SetScript("OnClick", function()
		mailIndex = mailIndex - 1
		InboxPrevPage()
	end)

	for i = 1, 7 do
		local mailBoxButton = _G["MailItem"..i.."Button"]
		mailBoxButton:SetScript("OnClick", function(self)
			mailItemIndex = 7 * (mailIndex - 1) + tonumber(string.sub(self:GetName(), 9, 9))
			local modifiedClick = IsModifiedClick("MAILAUTOLOOTTOGGLE")
			if modifiedClick then
				InboxFrame_OnModifiedClick(self, self.index)
			else
				InboxFrame_OnClick(self, self.index)
			end
		end)
	end

	local function OpenAll()
		if GetInboxNumItems() == 0 then return end
		button1:SetScript("OnClick", nil)
		button2:SetScript("OnClick", nil)
		button3:SetScript("OnClick", nil)
		imOrig_InboxFrame_OnClick = InboxFrame_OnClick
		InboxFrame_OnClick = B.Dummy
		if onlyCurrentMail then
			button3:RegisterEvent("UI_ERROR_MESSAGE")
			OpenMail(button3, mailItemIndex)
		else
			button1:RegisterEvent("UI_ERROR_MESSAGE")
			OpenMail(button1, GetInboxNumItems())
		end
	end

	local function WaitForMail(self, arg1)
		t = t + arg1
		if (not needsToWait) or (t > deletedelay) then
			t = 0
			needsToWait = false
			self:SetScript("OnUpdate", nil)

			local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(lastopened)
			if skipMail then
				OpenMail(self, lastopened - 1)
			elseif money > 0 or (not takingOnlyCash and numItems and numItems > 0 and COD <= 0) then
				OpenMail(self, lastopened)
			else
				OpenMail(self, lastopened - 1)
			end
		end
	end

	function OpenMail(button, index)
		if not InboxFrame:IsVisible() or index == 0 then
			return StopOpening()
		end
		local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
		if not takingOnlyCash then
			if money > 0 or (numItems and numItems > 0) and COD <= 0 then
				AutoLootMailItem(index)
				needsToWait = true
			end
			if onlyCurrentMail then StopOpening() return end
		elseif money > 0 then
			TakeInboxMoney(index)
			needsToWait = true
		end

		local items = GetInboxNumItems()
		if (numItems and numItems > 0) or (items > 1 and index <= items) then
			lastopened = index
			button:SetScript("OnUpdate", WaitForMail)
		else
			StopOpening()
		end
	end

	function StopOpening()
		button1:SetScript("OnUpdate", nil)
		button1:SetScript("OnClick", function() onlyCurrentMail = false OpenAll() end)
		button2:SetScript("OnClick", function() takingOnlyCash = true OpenAll() end)
		button3:SetScript("OnUpdate", nil)
		button3:SetScript("OnClick", function() onlyCurrentMail = true OpenAll() end)
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

	local function OpenAll_OnEvent(_, event, _, arg)
		if event == "UI_ERROR_MESSAGE" then
			if arg == ERR_INV_FULL then
				StopOpening()
			elseif arg == ERR_ITEM_MAX_COUNT then
				skipMail = true
			end
		elseif event == "MAIL_CLOSED" then
			if not hasNewMail then
				MiniMapMailFrame:Hide()
			end
			StopOpening()
		end
	end

	local function TotalCash_OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local total_cash = 0
		for index = 0, GetInboxNumItems() do
			total_cash = total_cash + select(5, GetInboxHeaderInfo(index))
		end
		if total_cash > 0 then SetTooltipMoney(GameTooltip, total_cash)	end
		GameTooltip:Show()
	end

	local function CreatButton(id, parent, text, w, h, ap, frame, rp, x, y)
		local button = CreateFrame("Button", id, parent, "UIPanelButtonTemplate")
		button:SetWidth(w)
		button:SetHeight(h)
		button:SetPoint(ap, frame, rp, x, y)
		button:SetText(text)
		return button
	end

	button1 = CreatButton(nil, InboxFrame, L["Collect All"], 80, 28, "TOPLEFT", "InboxFrame", "TOPLEFT", 50, -35)
	button1:RegisterEvent("MAIL_CLOSED")
	button1:SetScript("OnClick", OpenAll)
	button1:SetScript("OnEvent", OpenAll_OnEvent)

	button2 = CreatButton(nil, InboxFrame, L["Collect Gold"], 80, 28, "LEFT", button1, "RIGHT", 15, 0)
	button2:SetScript("OnClick", function() takingOnlyCash = true OpenAll() end)
	button2:SetScript("OnEnter", TotalCash_OnEnter)
	button2:SetScript("OnUpdate", function(self) if GameTooltip:IsOwned(self) then TotalCash_OnEnter(self) end end)
	button2:SetScript("OnLeave", GameTooltip_Hide)

	button3 = CreatButton(nil, OpenMailFrame, L["Collect Letters"], 82, 22, "RIGHT", "OpenMailReplyButton", "LEFT", 0, 0)
	button3:SetScript("OnClick", function() onlyCurrentMail = true OpenAll() end)
	button3:SetScript("OnEvent", OpenAll_OnEvent)

	button4 = CreatButton(nil, InboxFrame, REFRESH, 60, 28, "LEFT", button2, "RIGHT", 15, 0)
	button4:SetScript("OnClick", function() CheckInbox() end)

	local function deleteClick(self)
		local selectedID = self.id + (InboxFrame.pageNum-1)*7
		if InboxItemCanDelete(selectedID) then
			DeleteInboxItem(selectedID)
		else
			UIErrorsFrame:AddMessage(DB.InfoColor..ERR_MAIL_DELETE_ITEM_ERROR)
		end
	end

	hooksecurefunc("InboxFrame_Update", function()
		hasNewMail = false
		if select(4, GetInboxHeaderInfo(1)) then
			for i = 1, GetInboxNumItems() do
				local wasRead = select(9, GetInboxHeaderInfo(i))
				if (not wasRead) then
					hasNewMail = true
					break
				end
			end
		end

		for i = 1, 7 do
			local b = _G["MailItem"..i.."ExpireTime"]
			if not b.delete then
				b.delete = CreateFrame("BUTTON", nil, b)
				b.delete:SetPoint("TOPRIGHT", b, "BOTTOMRIGHT", -5, -1)
				b.delete:SetWidth(16)
				b.delete:SetHeight(16)
				b.delete.texture = b.delete:CreateTexture(nil, "BACKGROUND")
				b.delete.texture:SetAllPoints()
				b.delete.texture:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
				b.delete.texture:SetTexCoord(1, 0, 0, 1)
				b.delete.id = i
				b.delete:SetScript("OnClick", deleteClick)
				B.AddTooltip(b.delete, "ANCHOR_RIGHT", DELETE, "system")
			end
		end
	end)

	hooksecurefunc("InboxFrameItem_OnEnter", function(self)
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
	end)

	-- Replace the alert frame
	if InboxTooMuchMail then
		InboxTooMuchMail:ClearAllPoints()
		InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)
	end

	-- Aurora Reskin
	if IsAddOnLoaded("AuroraClassic") then
		local F = unpack(AuroraClassic)
		F.Reskin(button1)
		F.Reskin(button2)
		F.Reskin(button3)
		F.Reskin(button4)
	end

	-- Hide Blizz
	OpenAllMail:Hide()
	OpenAllMail:UnregisterAllEvents()
end