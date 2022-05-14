local _, ns = ...
local B, C, L, DB = unpack(ns)

local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags

local ipairs, strmatch, unpack, ceil = ipairs, string.match, unpack, math.ceil
local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE
local LE_ITEM_CLASS_QUIVER, LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_QUIVER, LE_ITEM_CLASS_CONTAINER
local GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem = GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem
local C_NewItems_IsNewItem, C_NewItems_RemoveNewItem = C_NewItems.IsNewItem, C_NewItems.RemoveNewItem
local IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown, DeleteCursorItem = IsControlKeyDown, IsAltKeyDown, IsShiftKeyDown, DeleteCursorItem
local SortBankBags, SortBags, InCombatLockdown, ClearCursor = SortBankBags, SortBags, InCombatLockdown, ClearCursor
local GetContainerItemID, SplitContainerItem = GetContainerItemID, SplitContainerItem
local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS or 7
local ITEM_STARTS_QUEST = ITEM_STARTS_QUEST

local anchorCache = {}

function module:UpdateBagsAnchor(parent, bags)
	wipe(anchorCache)

	local index = 1
	local perRow = C.db["Bags"]["BagsPerRow"]
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if (index-1) % perRow == 0 then
				bag:SetPoint("BOTTOMRIGHT", anchorCache[index-perRow], "BOTTOMLEFT", -5, 0)
			else
				bag:SetPoint("BOTTOMLEFT", anchorCache[index-1], "TOPLEFT", 0, 5)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

function module:UpdateBankAnchor(parent, bags)
	wipe(anchorCache)

	local index = 1
	local perRow = C.db["Bags"]["BankPerRow"]
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if index <= perRow then
				bag:SetPoint("BOTTOMLEFT", anchorCache[index-1], "TOPLEFT", 0, 5)
			elseif index == perRow+1 then
				bag:SetPoint("TOPLEFT", anchorCache[index-1], "TOPRIGHT", 5, 0)
			elseif (index-1) % perRow == 0 then
				bag:SetPoint("TOPLEFT", anchorCache[index-perRow], "TOPRIGHT", 5, 0)
			else
				bag:SetPoint("TOPLEFT", anchorCache[index-1], "BOTTOMLEFT", 0, -5)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

local function highlightFunction(button, match)
	button.searchOverlay:SetShown(not match)
end

local function IsItemMatched(str, text)
	if not str or str == "" then return end
	return strmatch(strlower(str), text)
end

local BagSmartFilter = {
	default = function(item, text)
		text = strlower(text)
		if text == "boe" then
			return item.bindOn == "equip"
		else
			return IsItemMatched(item.subType, text) or IsItemMatched(item.equipLoc, text) or IsItemMatched(item.name, text)
		end
	end,
	_default = "default",
}

function module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(140, 32)
	local icon = infoFrame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(20, 20)
	icon:SetPoint("LEFT", 0, -1)
	icon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
	icon:SetVertexColor(DB.r, DB.g, DB.b)
	local hl = infoFrame:CreateTexture(nil, "HIGHLIGHT")
	hl:SetSize(20, 20)
	hl:SetPoint("LEFT", 0, -1)
	hl:SetTexture("Interface\\Common\\UI-Searchbox-Icon")

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(search, 0, true)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	search.textFilters = BagSmartFilter

	infoFrame.title = SEARCH
	B.AddTooltip(infoFrame, "ANCHOR_TOPLEFT", DB.InfoColor..L["BagSearchTip"])
end

local function ToggleWidgetButtons(self)
	C.db["Bags"]["HideWidgets"] = not C.db["Bags"]["HideWidgets"]

	local buttons = self.__owner.widgetButtons

	for index, button in pairs(buttons) do
		if index > 2 then
			button:SetShown(not C.db["Bags"]["HideWidgets"])
		end
	end

	if C.db["Bags"]["HideWidgets"] then
		self:SetPoint("RIGHT", buttons[2], "LEFT", -1, 0)
		B.SetupArrow(self.__texture, "left")
		self.tag:Show()
	else
		self:SetPoint("RIGHT", buttons[#buttons], "LEFT", -1, 0)
		B.SetupArrow(self.__texture, "right")
		self.tag:Hide()
	end
	self:Show()
end

function module:CreateCollapseArrow()
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(20, 20)
	local tex = bu:CreateTexture()
	tex:SetAllPoints()
	B.SetupArrow(tex, "right")
	bu.__texture = tex
	bu:SetScript("OnEnter", B.Texture_OnEnter)
	bu:SetScript("OnLeave", B.Texture_OnLeave)

	local tag = self:SpawnPlugin("TagDisplay", "[money]", self)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("RIGHT", bu, "LEFT", -12, 0)
	bu.tag = tag

	bu.__owner = self
	C.db["Bags"]["HideWidgets"] = not C.db["Bags"]["HideWidgets"] -- reset before toggle
	ToggleWidgetButtons(bu)
	bu:SetScript("OnClick", ToggleWidgetButtons)

	self.widgetArrow = bu
end

local function updateBagBar(bar)
	local spacing = 3
	local offset = 5
	local width, height = bar:LayoutButtons("grid", bar.columns, spacing, offset, -offset)
	bar:SetSize(width + offset*2, height + offset*2)
end

function module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	B.SetBD(bagBar)
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()
	bagBar.columns = columns
	bagBar.UpdateAnchor = updateBagBar
	bagBar:UpdateAnchor()

	self.BagBar = bagBar
end

local function CloseOrRestoreBags(self, btn)
	if btn == "RightButton" then
		local bag = self.__owner.main
		local bank = self.__owner.bank
		C.db["TempAnchor"][bag:GetName()] = nil
		C.db["TempAnchor"][bank:GetName()] = nil
		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	else
		CloseAllBags()
	end
end

function module:CreateCloseButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	bu:RegisterForClicks("AnyUp")
	bu.__owner = f
	bu:SetScript("OnClick", CloseOrRestoreBags)
	bu.title = CLOSE.."/"..RESET
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function ToggleBackpacks(self)
	local parent = self.__owner
	B:TogglePanel(parent.BagBar)
	if parent.BagBar:IsShown() then
		self.bg:SetBackdropBorderColor(1, .8, 0)
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		if parent.keyring and parent.keyring:IsShown() then parent.keyToggle:Click() end
	else
		B.SetBorderColor(self.bg)
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end
end

function module:CreateBagToggle()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Buttons\\Button-Backpack-Up")
	bu.__owner = self
	bu:SetScript("OnClick", ToggleBackpacks)
	bu.title = BACKPACK_TOOLTIP
	B.AddTooltip(bu, "ANCHOR_TOP")
	self.bagToggle = bu

	return bu
end

function module:CreateKeyToggle()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\ICONS\\INV_Misc_Key_12")
	bu:SetScript("OnClick", function()
		ToggleFrame(self.keyring)
		if self.keyring:IsShown() then
			bu.bg:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.KEY_RING_OPEN)
			if self.BagBar and self.BagBar:IsShown() then self.bagToggle:Click() end
		else
			B.SetBorderColor(bu.bg)
			PlaySound(SOUNDKIT.KEY_RING_CLOSE)
		end
	end)
	bu.title = KEYRING
	B.AddTooltip(bu, "ANCHOR_TOP")
	self.keyToggle = bu

	return bu
end

function module:CreateSortButton(name)
	local bu = B.CreateButton(self, 22, 22, true, DB.sortTex)
	bu:SetScript("OnClick", function()
		if C.db["Bags"]["BagSortMode"] == 3 then
			UIErrorsFrame:AddMessage(DB.InfoColor..L["BagSortDisabled"])
			return
		end

		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

		if name == "Bank" then
			SortBankBags()
		else
			SortBags()
		end
	end)
	bu.title = L["Sort"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:GetContainerEmptySlot(bagID)
	local bagType = module.BagsType[bagID]
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) and bagType == 0 then
			return slotID
		end
	end
end

function module:GetEmptySlot(name)
	if name == "Bag" then
		for bagID = 0, NUM_BAG_SLOTS do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		local slotID = module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end
		for bagID = NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function module:FreeSlotOnDrop()
	local bagID, slotID = module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Bag"] = true,
	["Bank"] = true,
}

function module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then return end

	local slot = CreateFrame("Button", name.."FreeSlot", self, "BackdropTemplate")
	slot:SetSize(self.iconSize, self.iconSize)
	slot:SetHighlightTexture(DB.bdTex)
	slot:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
	slot:GetHighlightTexture():SetInside()
	B.CreateBD(slot, .3)
	slot:SetBackdropColor(.3, .3, .3, .3)
	slot:SetScript("OnMouseUp", module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", module.FreeSlotOnDrop)
	B.AddTooltip(slot, "ANCHOR_RIGHT", L["FreeSlots"])
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	tag:SetFont(DB.Font[1], C.db["Bags"]["FontSize"] + 2, DB.Font[3])
	tag:SetTextColor(.6, .8, 1)
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name
	slot.tag = tag

	self.freeSlot = slot
end

local toggleButtons = {}
function module:SelectToggleButton(id)
	for index, button in pairs(toggleButtons) do
		if index ~= id then
			button.__turnOff()
		end
	end
end

local splitEnable
local function saveSplitCount(self)
	local count = self:GetText() or ""
	C.db["Bags"]["SplitCount"] = tonumber(count) or 1
end

function module:CreateSplitButton()
	local enabledText = DB.InfoColor..L["SplitMode Enabled"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
	B.CreateFS(splitFrame, 14, L["SplitCount"], "system", "TOP", 1, -5)
	B.SetBD(splitFrame)
	splitFrame:Hide()
	local editbox = B.CreateEditBox(splitFrame, 90, 20)
	editbox:SetPoint("BOTTOMLEFT", 5, 5)
	editbox:SetJustifyH("CENTER")
	editbox:SetScript("OnTextChanged", saveSplitCount)

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")
	bu.Icon:SetPoint("TOPLEFT", -1, 3)
	bu.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		splitFrame:Hide()
		splitEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(1)
		splitEnable = not splitEnable
		if splitEnable then
			self.bg:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
			splitFrame:Show()
			editbox:SetText(C.db["Bags"]["SplitCount"])
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["QuickSplit"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[1] = bu

	return bu
end

local function splitOnClick(self)
	if not splitEnable then return end

	PickupContainerItem(self.bagID, self.slotID)

	local texture, itemCount, locked = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and not locked and itemCount and itemCount > C.db["Bags"]["SplitCount"] then
		SplitContainerItem(self.bagID, self.slotID, C.db["Bags"]["SplitCount"])

		local bagID, slotID = module:GetEmptySlot("Bag")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

local favouriteEnable

local function GetCustomGroupTitle(index)
	return C.db["Bags"]["CustomNames"][index] or (PREFERENCES.." "..index)
end

StaticPopupDialogs["NDUI_RENAMECUSTOMGROUP"] = {
	text = BATTLE_PET_RENAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		local index = module.selectGroupIndex
		local text = self.editBox:GetText()
		C.db["Bags"]["CustomNames"][index] = text ~= "" and text or nil

		module.CustomMenu[index+2].text = GetCustomGroupTitle(index)
		module.ContainerGroups["Bag"][index].label:SetText(GetCustomGroupTitle(index))
		module.ContainerGroups["Bank"][index].label:SetText(GetCustomGroupTitle(index))
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function module:RenameCustomGroup(index)
	module.selectGroupIndex = index
	StaticPopup_Show("NDUI_RENAMECUSTOMGROUP")
end

function module:MoveItemToCustomBag(index)
	local itemID = module.selectItemID
	if index == 0 then
		if C.db["Bags"]["CustomItems"][itemID] then
			C.db["Bags"]["CustomItems"][itemID] = nil
		end
	else
		C.db["Bags"]["CustomItems"][itemID] = index
	end
	module:UpdateAllBags()
end

function module:IsItemInCustomBag()
	local index = self.arg1
	local itemID = module.selectItemID
	return (index == 0 and not C.db["Bags"]["CustomItems"][itemID]) or (C.db["Bags"]["CustomItems"][itemID] == index)
end

function module:CreateFavouriteButton()
	local menuList = {
		{text = "", icon = 134400, isTitle = true, notCheckable = true, tCoordLeft = .08, tCoordRight = .92, tCoordTop = .08, tCoordBottom = .92},
		{text = NONE, arg1 = 0, func = module.MoveItemToCustomBag, checked = module.IsItemInCustomBag},
	}
	for i = 1, 5 do
		tinsert(menuList, {
			text = GetCustomGroupTitle(i), arg1 = i, func = module.MoveItemToCustomBag, checked = module.IsItemInCustomBag, hasArrow = true,
			menuList = {{text = BATTLE_PET_RENAME, arg1 = i, func = module.RenameCustomGroup}}
		})
	end
	module.CustomMenu = menuList

	local enabledText = DB.InfoColor..L["FavouriteMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Common\\friendship-heart")
	bu.Icon:SetPoint("TOPLEFT", -5, 0)
	bu.Icon:SetPoint("BOTTOMRIGHT", 5, -5)
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		favouriteEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(2)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self.bg:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["FavouriteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[2] = bu

	return bu
end

local function favouriteOnClick(self)
	if not favouriteEnable then return end

	local texture, _, _, quality, _, _, link, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		ClearCursor()
		module.selectItemID = itemID
		module.CustomMenu[1].text = link
		module.CustomMenu[1].icon = texture
		EasyMenu(module.CustomMenu, B.EasyMenu, self, 0, 0, "MENU")
	end
end

StaticPopupDialogs["NDUI_WIPE_JUNK_LIST"] = {
	text = L["Reset junklist warning"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(NDuiADB["CustomJunkList"])
	end,
	whileDead = 1,
}
local customJunkEnable
function module:CreateJunkButton()
	local enabledText = DB.InfoColor..L["JunkMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")
	bu.Icon:SetPoint("TOPLEFT", C.mult, -3)
	bu.Icon:SetPoint("BOTTOMRIGHT", -C.mult, -3)
	bu.__turnOff = function()
		B.SetBorderColor(bu.bg)
		bu.text = nil
		customJunkEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		if IsAltKeyDown() and IsControlKeyDown() then
			StaticPopup_Show("NDUI_WIPE_JUNK_LIST")
			return
		end

		module:SelectToggleButton(3)
		customJunkEnable = not customJunkEnable
		if customJunkEnable then
			self.bg:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			bu.__turnOff()
		end
		module:UpdateAllBags()
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["CustomJunkMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[3] = bu

	return bu
end

local function customJunkOnClick(self)
	if not customJunkEnable then return end

	local texture, _, _, _, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	local price = select(11, GetItemInfo(itemID))
	if texture and price > 0 then
		if NDuiADB["CustomJunkList"][itemID] then
			NDuiADB["CustomJunkList"][itemID] = nil
		else
			NDuiADB["CustomJunkList"][itemID] = true
		end
		ClearCursor()
		module:UpdateAllBags()
	end
end

local deleteEnable
function module:CreateDeleteButton()
	local enabledText = DB.InfoColor..L["DeleteMode Enabled"]

	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	bu.Icon:SetPoint("TOPLEFT", 3, -2)
	bu.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	bu.__turnOff = function()
		bu.bg:SetBackdropBorderColor(0, 0, 0)
		bu.text = nil
		deleteEnable = nil
	end
	bu:SetScript("OnClick", function(self)
		module:SelectToggleButton(4)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self.bg:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			bu.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu:SetScript("OnHide", bu.__turnOff)
	bu.title = L["ItemDeleteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	toggleButtons[4] = bu

	return bu
end

local function deleteButtonOnClick(self)
	if not deleteEnable then return end

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

function module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then return end
	splitOnClick(self)
	favouriteOnClick(self)
	customJunkOnClick(self)
	deleteButtonOnClick(self)
end

function module:UpdateAllBags()
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function module:OpenBags()
	OpenAllBags(true)
end

function module:CloseBags()
	CloseAllBags()
end

local questItemCache = {}
function module:IsAcceptableQuestItem(link)
	if not link then return end

	local canAccept = questItemCache[link]
	if not canAccept then
		B.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
		B.ScanTip:SetHyperlink(link)

		for i = 2, B.ScanTip:NumLines() do
			local line = _G["NDui_ScanTooltipTextLeft"..i]
			local lineText = line and line:GetText()
			if lineText and strmatch(lineText, ITEM_STARTS_QUEST) then
				canAccept = true
				questItemCache[link] = true
				break
			end
		end
	end

	return canAccept
end

function module:OnLogin()
	if not C.db["Bags"]["Enable"] then return end

	-- Settings
	local iconSize = C.db["Bags"]["IconSize"]
	local showNewItem = C.db["Bags"]["ShowNewItem"]
	local hasPawn = IsAddOnLoaded("Pawn")

	-- Init
	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
	Backpack:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

	module.Bags = Backpack
	module.BagsType = {}
	module.BagsType[0] = 0	-- backpack
	module.BagsType[-1] = 0	-- bank

	local f = {}
	local filters = module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	module.ContainerGroups = {["Bag"] = {}, ["Bank"] = {}}

	local function AddNewContainer(bagType, index, name, filter)
		local newContainer = MyContainer:New(name, {BagType = bagType, Index = index})
		newContainer:SetFilter(filter, true)
		module.ContainerGroups[bagType][index] = newContainer
	end

	function Backpack:OnInit()
		AddNewContainer("Bag", 11, "Junk", filters.bagsJunk)
		for i = 1, 5 do
			AddNewContainer("Bag", i, "BagCustom"..i, filters["bagCustom"..i])
		end
		AddNewContainer("Bag", 6, "AmmoItem", filters.bagAmmo)
		AddNewContainer("Bag", 7, "Equipment", filters.bagEquipment)
		AddNewContainer("Bag", 9, "Consumable", filters.bagConsumable)
		AddNewContainer("Bag", 8, "BagGoods", filters.bagGoods)
		AddNewContainer("Bag", 10, "BagQuest", filters.bagQuest)

		f.main = MyContainer:New("Bag", {Bags = "bags", BagType = "Bag"})
		f.main.__anchor = {"BOTTOMRIGHT", -50, 100}
		f.main:SetPoint(unpack(f.main.__anchor))
		f.main:SetFilter(filters.onlyBags, true)

		local keyring = MyContainer:New("Keyring", {BagType = "Bag", Parent = f.main})
		keyring:SetFilter(filters.onlyKeyring, true)
		keyring:SetPoint("TOPRIGHT", f.main, "BOTTOMRIGHT", 0, -5)
		keyring:Hide()
		f.main.keyring = keyring
	
		for i = 1, 5 do
			AddNewContainer("Bank", i, "BankCustom"..i, filters["bankCustom"..i])
		end
		AddNewContainer("Bank", 6, "bankAmmoItem", filters.bankAmmo)
		AddNewContainer("Bank", 8, "BankLegendary", filters.bankLegendary)
		AddNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
		AddNewContainer("Bank", 10, "BankConsumable", filters.bankConsumable)
		AddNewContainer("Bank", 9, "BankGoods", filters.bankGoods)
		AddNewContainer("Bank", 11, "BankQuest", filters.bankQuest)

		f.bank = MyContainer:New("Bank", {Bags = "bank", BagType = "Bank"})
		f.bank.__anchor = {"BOTTOMLEFT", 25, 50}
		f.bank:SetPoint(unpack(f.bank.__anchor))
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		for bagType, groups in pairs(module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				B.CreateMF(container, parent, true)
			end
		end
	end

	local initBagType
	function Backpack:OnBankOpened()
		self:GetContainer("Bank"):Show()

		if not initBagType then
			module:UpdateAllBags() -- Initialize bagType
			module:UpdateBagSize()
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetHighlightTexture(DB.bdTex)
		self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		self:GetHighlightTexture():SetInside()
		self:SetSize(iconSize, iconSize)

		self.Icon:SetInside()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Count:SetPoint("BOTTOMRIGHT", -1, 2)
		self.Count:SetFont(DB.Font[1], C.db["Bags"]["FontSize"], DB.Font[3])
		self.Cooldown:SetInside()

		B.CreateBD(self, .3)
		self:SetBackdropColor(.3, .3, .3, .3)

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		self.Favourite = parentFrame:CreateTexture(nil, "ARTWORK")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(30, 30)
		self.Favourite:SetPoint("TOPLEFT", -12, 9)

		self.Quest = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)
		self.iLvl = B.CreateFS(self, C.db["Bags"]["FontSize"], "", false, "BOTTOMLEFT", 1, 2)

		if showNewItem then
			self.glowFrame = B.CreateGlowFrame(self, iconSize)
		end

		self:HookScript("OnClick", module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame then
			B.HideOverlayGlow(self.glowFrame)
			C_NewItems_RemoveNewItem(self.bagID, self.slotID)
		end
	end

	local bagTypeColor = {
		[-1] = {.67, .83, .45, .25},-- 箭袋/弹药
		[0] = {.3, .3, .3, .3},		-- 容器
		[1] = {.53, .53, .93, .25}, -- 灵魂袋
		[2] = {0, .5, 0, .25},		-- 草药袋
		[3] = {.8, 0, .8, .25},		-- 附魔袋
		[4] = {1, .8, 0, .25},		-- 工程袋
		[5] = {0, .8, .8, .25},		-- 宝石袋
		[6] = {.5, .4, 0, .25},		-- 矿石袋
		[7] = {.8, .5, .5, .25},	-- 制皮包
		[8] = {.8, .8, .8, .25},	-- 铭文包
		[9] = {.4, .6, 1, .25},		-- 工具箱
		[10] = {.8, 0, 0, .25},		-- 烹饪包
	}

	local function isItemNeedsLevel(item)
		return item.link and item.quality > 1 and module:IsItemHasLevel(item)
	end

	local function UpdatePawnArrow(self, item)
		if not hasPawn then return end
		if not PawnIsContainerItemAnUpgrade then return end
		if self.UpgradeIcon then
			self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagID, item.slotID))
		end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if self.JunkIcon then
			if (MerchantFrame:IsShown() or customJunkEnable) and (item.quality == LE_ITEM_QUALITY_POOR or NDuiADB["CustomJunkList"][item.id]) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		if C.db["Bags"]["CustomItems"][item.id] and not C.db["Bags"]["ItemFilter"] then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if C.db["Bags"]["BagsiLvl"] and isItemNeedsLevel(item) then
			local level = item.level
			if level and level > C.db["Bags"]["iLvlToShow"] then
				local color = DB.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				B.ShowOverlayGlow(self.glowFrame)
			else
				B.HideOverlayGlow(self.glowFrame)
			end
		end

		if C.db["Bags"]["SpecialBagsColor"] then
			local bagType = module.BagsType[item.bagID]
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self:SetBackdropColor(unpack(color))
		else
			self:SetBackdropColor(.3, .3, .3, .3)
		end

		-- Hide empty tooltip
		if not item.texture and GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end

		-- Support Pawn
		UpdatePawnArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.isQuestItem then
			self:SetBackdropBorderColor(.8, .8, 0)
		elseif item.quality and item.quality > -1 then
			local color = DB.QualityColors[item.quality]
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end

		self.Quest:SetShown(item.isQuestItem and module:IsAcceptableQuestItem(item.link))
	end

	function module:UpdateAllAnchors()
		module:UpdateBagsAnchor(f.main, module.ContainerGroups["Bag"])
		module:UpdateBankAnchor(f.bank, module.ContainerGroups["Bank"])
	end

	function module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C.db["Bags"]["BagsWidth"]
		elseif bagType == "Bank" then
			return C.db["Bags"]["BankWidth"]
		end
	end

	function MyContainer:OnContentsChanged(gridOnly)
		self:SortButtons("bagSlot")

		local columns = module:GetContainerColumns(self.Settings.BagType)
		local offset = 38
		local spacing = 3
		local xOffset = 5
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize+spacing)-spacing
		if self.freeSlot then
			if C.db["Bags"]["GatherEmpty"] then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then col = columns end
				local xPos = (col-1) * (iconSize + spacing)
				local yPos = -1 * (row-1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos+yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset*2, height + offset)

		if not gridOnly then
			module:UpdateAllAnchors()
		end
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		B.SetBD(self)
		if settings.Bags then
			B.CreateMF(self, nil, true)
		end

		local label
		if strmatch(name, "AmmoItem$") then
			label = DB.MyClass == "HUNTER" and INVTYPE_AMMO or SOUL_SHARDS
		elseif strmatch(name, "Equipment$") then
			label = BAG_FILTER_EQUIPMENT
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumable$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif name == "Keyring" then
			label = KEYRING
		elseif strmatch(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		elseif strmatch(name, "Quest") then
			label = QUESTS_LABEL
		elseif strmatch(name, "Custom%d") then
			label = GetCustomGroupTitle(settings.Index)
		end
		if label then
			self.label = B.CreateFS(self, 14, label, true, "TOPLEFT", 5, -8)
			return
		end

		self.iconSize = iconSize
		module.CreateInfoFrame(self)
		module.CreateFreeSlots(self)

		local buttons = {}
		buttons[1] = module.CreateCloseButton(self, f)
		if name == "Bag" then
			module.CreateBagBar(self, settings, NUM_BAG_SLOTS)
			buttons[2] = module.CreateSortButton(self, name)
			buttons[3] = module.CreateBagToggle(self)
			buttons[4] = module.CreateKeyToggle(self)
			buttons[5] = module.CreateSplitButton(self)
			buttons[6] = module.CreateFavouriteButton(self)
			buttons[7] = module.CreateJunkButton(self)
			buttons[8] = module.CreateDeleteButton(self)
		elseif name == "Bank" then
			module.CreateBagBar(self, settings, NUM_BANKBAGSLOTS)
			buttons[2] = module.CreateBagToggle(self)
			buttons[3] = module.CreateSortButton(self, name)
		end

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -5, -5)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -3, 0)
			end
		end
		self.widgetButtons = buttons

		if name == "Bag" then module.CreateCollapseArrow(self) end

		self:HookScript("OnShow", B.RestoreMF)
	end

	local function updateBagSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetSize(iconSize+8, iconSize+8)
		end
		button.Count:SetFont(DB.Font[1], C.db["Bags"]["FontSize"], DB.Font[3])
		button.iLvl:SetFont(DB.Font[1], C.db["Bags"]["FontSize"], DB.Font[3])
	end

	function module:UpdateBagSize()
		iconSize = C.db["Bags"]["IconSize"]
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(updateBagSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
				container.freeSlot.tag:SetFont(DB.Font[1], C.db["Bags"]["FontSize"]+2, DB.Font[3])
			end
			if container.BagBar then
				for _, bagButton in pairs(container.BagBar.buttons) do
					bagButton:SetSize(iconSize, iconSize)
				end
				container.BagBar:UpdateAnchor()
			end
			container:OnContentsChanged(true)
		end
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetHighlightTexture(DB.bdTex)
		self:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		self:GetHighlightTexture():SetInside()

		self:SetSize(iconSize, iconSize)
		B.CreateBD(self, .25)
		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then return end
		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(id)
		if not quality or quality == 1 then quality = 0 end
		local color = DB.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			module.BagsType[self.bagID] = subClassID or 0
		elseif classID == LE_ITEM_CLASS_QUIVER then
			module.BagsType[self.bagID] = -1
		else
			module.BagsType[self.bagID] = 0
		end
	end

	-- Sort order
	SetSortBagsRightToLeft(C.db["Bags"]["BagSortMode"] == 1)
	SetInsertItemsLeftToRight(false)

	-- Init
	ToggleAllBags()
	ToggleAllBags()
	module.initComplete = true

	B:RegisterEvent("TRADE_SHOW", module.OpenBags)
	--B:RegisterEvent("TRADE_CLOSED", module.CloseBags)
	B:RegisterEvent("AUCTION_HOUSE_SHOW", module.OpenBags)
	B:RegisterEvent("AUCTION_HOUSE_CLOSED", module.CloseBags)

	-- Update infobar slots
	local INFO = B:GetModule("Infobar")
	if INFO.modules then
		for _, info in pairs(INFO.modules) do
			if info.name == "Gold" then
				Backpack.OnOpen = function()
					if not NDuiADB["ShowSlots"] then return end
					info:onEvent()
				end
				break
			end
		end
	end

	-- Fixes
	BankFrame.GetRight = function() return f.bank:GetRight() end
	BankFrameItemButton_Update = B.Dummy

	-- Shift key alert
	local function onUpdate(self, elapsed)
		if IsShiftKeyDown() then
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > 5 then
				UIErrorsFrame:AddMessage(DB.InfoColor..L["StupidShiftKey"])
				self.elapsed = 0
			end
		end
	end
	local shiftUpdater = CreateFrame("Frame", nil, f.main)
	shiftUpdater:SetScript("OnUpdate", onUpdate)
end