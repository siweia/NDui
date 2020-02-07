local _, ns = ...
local B, C, L, DB = unpack(ns)

local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags
local ipairs, strmatch, unpack, ceil = ipairs, string.match, unpack, math.ceil
local BAG_ITEM_QUALITY_COLORS, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC = BAG_ITEM_QUALITY_COLORS, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC
local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE, LE_ITEM_QUALITY_HEIRLOOM = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE, LE_ITEM_QUALITY_HEIRLOOM
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_CONTAINER
local SortBankBags, SortReagentBankBags, SortBags = SortBankBags, SortReagentBankBags, SortBags
local GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem = GetContainerNumSlots, GetContainerItemInfo, PickupContainerItem
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID, C_NewItems_IsNewItem, C_NewItems_RemoveNewItem, C_Timer_After = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID, C_NewItems.IsNewItem, C_NewItems.RemoveNewItem, C_Timer.After
local IsControlKeyDown, IsAltKeyDown, DeleteCursorItem = IsControlKeyDown, IsAltKeyDown, DeleteCursorItem
local GetItemInfo, GetContainerItemID, SplitContainerItem = GetItemInfo, GetContainerItemID, SplitContainerItem
local IsCorruptedItem = IsCorruptedItem

local sortCache = {}
function module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if (slot <= numSlots/2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots+1 - slot)
				sortCache["b"..bag.."s"..slot] = true
			end
		end
	end

	module.Bags.isSorting = false
	module:UpdateAllBags()
end

function module:UpdateAnchors(parent, bags)
	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end
		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 5)
			anchor = bag
		end
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

function module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(160, 32)
	local icon = infoFrame:CreateTexture()
	icon:SetSize(24, 24)
	icon:SetPoint("LEFT")
	icon:SetTexture("Interface\\Minimap\\Tracking\\None")
	icon:SetTexCoord(1, 0, 0, 1)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	local bg = B.CreateBDFrame(search, 0)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	B.CreateGradient(bg)

	local tag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("LEFT", icon, "RIGHT", 5, 0)
end

function module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 5, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	B.SetBD(bagBar)
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function module:CreateCloseButton()
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	bu:SetScript("OnClick", CloseAllBags)
	bu.title = CLOSE
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateRestoreButton(f)
	local bu = B.CreateButton(self, 24, 24, true, "Atlas:transmog-icon-revert")
	bu:SetScript("OnClick", function()
		NDuiDB["TempAnchor"][f.main:GetName()] = nil
		NDuiDB["TempAnchor"][f.bank:GetName()] = nil
		NDuiDB["TempAnchor"][f.reagent:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -50, 50)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.reagent:ClearAllPoints()
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	bu.title = RESET
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateReagentButton(f)
	local bu = B.CreateButton(self, 24, 24, true, "Atlas:Reagents")
	bu.Icon:SetPoint("BOTTOMRIGHT", -C.mult, -C.mult)
	bu:RegisterForClicks("AnyUp")
	bu:SetScript("OnClick", function(_, btn)
		if not IsReagentBankUnlocked() then
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			ReagentBankFrame:Show()
			BankFrame.selectedTab = 2
			f.reagent:Show()
			f.bank:Hide()
			if btn == "RightButton" then DepositReagentBank() end
		end
	end)
	bu.title = REAGENT_BANK
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateBankButton(f)
	local bu = B.CreateButton(self, 24, 24, true, "Atlas:Banker")
	bu:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		ReagentBankFrame:Hide()
		BankFrame.selectedTab = 1
		f.reagent:Hide()
		f.bank:Show()
	end)
	bu.title = BANK
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateDepositButton()
	local bu = B.CreateButton(self, 24, 24, true, "Atlas:GreenCross")
	bu.Icon:SetOutside()
	bu:SetScript("OnClick", DepositReagentBank)
	bu.title = REAGENTBANK_DEPOSIT
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateBagToggle()
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Buttons\\Button-Backpack-Up")
	bu:SetScript("OnClick", function()
		ToggleFrame(self.BagBar)
		if self.BagBar:IsShown() then
			bu:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bu:SetBackdropBorderColor(0, 0, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bu.title = BACKPACK_TOOLTIP
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

function module:CreateSortButton(name)
	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Icons\\INV_Pet_Broom")
	bu:SetScript("OnClick", function()
		if name == "Bank" then
			SortBankBags()
		elseif name == "Reagent" then
			SortReagentBankBags()
		else
			if NDuiDB["Bags"]["ReverseSort"] then
				if InCombatLockdown() then
					UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT)
				else
					SortBags()
					wipe(sortCache)
					module.Bags.isSorting = true
					C_Timer_After(.5, module.ReverseSort)
				end
			else
				SortBags()
			end
		end
	end)
	bu.title = L["Sort"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local deleteEnable
function module:CreateDeleteButton()
	local enabledText = DB.InfoColor..L["DeleteMode Enabled"]

	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	bu.Icon:SetPoint("TOPLEFT", 3, -2)
	bu.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	bu:SetScript("OnClick", function(self)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			self:SetBackdropBorderColor(0, 0, 0)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	bu.title = L["ItemDeleteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function deleteButtonOnClick(self)
	if not deleteEnable then return end

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE or quality == LE_ITEM_QUALITY_HEIRLOOM) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

local favouriteEnable
function module:CreateFavouriteButton()
	local enabledText = DB.InfoColor..L["FavouriteMode Enabled"]

	local bu = B.CreateButton(self, 24, 24, true, "Interface\\Common\\friendship-heart")
	bu.Icon:SetPoint("TOPLEFT", -5, 0)
	bu.Icon:SetPoint("BOTTOMRIGHT", 5, -5)
	bu:SetScript("OnClick", function(self)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
		else
			self:SetBackdropBorderColor(0, 0, 0)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	bu.title = L["FavouriteMode"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function favouriteOnClick(self)
	if not favouriteEnable then return end

	local texture, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		if NDuiDB["Bags"]["FavouriteItems"][itemID] then
			NDuiDB["Bags"]["FavouriteItems"][itemID] = nil
		else
			NDuiDB["Bags"]["FavouriteItems"][itemID] = true
		end
		ClearCursor()
		module:UpdateAllBags()
	end
end

function module:GetContainerEmptySlot(bagID)
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function module:GetEmptySlot(name)
	if name == "Main" then
		for bagID = 0, 4 do
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
		for bagID = 5, 11 do
			local slotID = module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Reagent" then
		local slotID = module:GetContainerEmptySlot(-3)
		if slotID then
			return -3, slotID
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
	["Main"] = true,
	["Bank"] = true,
	["Reagent"] = true,
}

function module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then return end

	local slot = CreateFrame("Button", name.."FreeSlot", self)
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
	tag:SetFont(DB.Font[1], DB.Font[2]+2, DB.Font[3])
	tag:SetTextColor(.6, .8, 1)
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name

	self.freeSlot = slot
end

local splitEnable
local function saveSplitCount(self)
	local count = self:GetText() or ""
	NDuiDB["Bags"]["SplitCount"] = tonumber(count) or 1
end

function module:CreateSplitButton()
	local enabledText = DB.InfoColor..L["SplitMode Enabled"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
	B.CreateFS(splitFrame, 14, L["SplitCount"], "system", "TOP", 1, -5)
	B.SetBD(splitFrame)
	splitFrame:Hide()
	local editbox = B.CreateEditBox(splitFrame, 90, 20)
	editbox:SetPoint("BOTTOMLEFT", 5, 5)
	editbox:SetJustifyH("CENTER")
	editbox:SetScript("OnTextChanged", saveSplitCount)

	local bu = B.CreateButton(self, 24, 24, true, "Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")
	bu.Icon:SetPoint("TOPLEFT", -1, 3)
	bu.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	bu:SetScript("OnClick", function(self)
		splitEnable = not splitEnable
		if splitEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.text = enabledText
			splitFrame:Show()
			editbox:SetText(NDuiDB["Bags"]["SplitCount"])
		else
			self:SetBackdropBorderColor(0, 0, 0)
			self.text = nil
			splitFrame:Hide()
		end
		self:GetScript("OnEnter")(self)
	end)
	bu.title = L["QuickSplit"]
	B.AddTooltip(bu, "ANCHOR_TOP")

	return bu
end

local function splitOnClick(self)
	if not splitEnable then return end

	PickupContainerItem(self.bagID, self.slotID)

	local texture, itemCount, locked = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and not locked and itemCount and itemCount > NDuiDB["Bags"]["SplitCount"] then
		SplitContainerItem(self.bagID, self.slotID, NDuiDB["Bags"]["SplitCount"])

		local bagID, slotID = module:GetEmptySlot("Main")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

function module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then return end
	deleteButtonOnClick(self)
	favouriteOnClick(self)
	splitOnClick(self)
end

function module:UpdateAllBags()
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function module:OnLogin()
	if not NDuiDB["Bags"]["Enable"] then return end

	-- Settings
	local bagsScale = NDuiDB["Bags"]["BagsScale"]
	local bagsWidth = NDuiDB["Bags"]["BagsWidth"]
	local bankWidth = NDuiDB["Bags"]["BankWidth"]
	local iconSize = NDuiDB["Bags"]["IconSize"]
	local deleteButton = NDuiDB["Bags"]["DeleteButton"]
	local itemSetFilter = NDuiDB["Bags"]["ItemSetFilter"]
	local showNewItem = NDuiDB["Bags"]["ShowNewItem"]

	-- Init
	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(bagsScale)
	Backpack:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
	Backpack:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

	module.Bags = Backpack
	module.BagsType = {}
	module.BagsType[0] = 0	-- backpack
	module.BagsType[-1] = 0	-- bank
	module.BagsType[-3] = 0	-- reagent

	local f = {}
	local filters = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetFilter(filters.onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -50, 50)

		f.junk = MyContainer:New("Junk", {Columns = bagsWidth, Parent = f.main})
		f.junk:SetFilter(filters.bagsJunk, true)

		f.bagFavourite = MyContainer:New("BagFavourite", {Columns = bagsWidth, Parent = f.main})
		f.bagFavourite:SetFilter(filters.bagFavourite, true)

		f.azeriteItem = MyContainer:New("AzeriteItem", {Columns = bagsWidth, Parent = f.main})
		f.azeriteItem:SetFilter(filters.bagAzeriteItem, true)

		f.equipment = MyContainer:New("Equipment", {Columns = bagsWidth, Parent = f.main})
		f.equipment:SetFilter(filters.bagEquipment, true)

		f.consumble = MyContainer:New("Consumble", {Columns = bagsWidth, Parent = f.main})
		f.consumble:SetFilter(filters.bagConsumble, true)

		f.bagCompanion = MyContainer:New("BagCompanion", {Columns = bagsWidth, Parent = f.main})
		f.bagCompanion:SetFilter(filters.bagMountPet, true)

		f.bagGoods = MyContainer:New("BagGoods", {Columns = bagsWidth, Parent = f.main})
		f.bagGoods:SetFilter(filters.bagGoods, true)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.bank:Hide()

		f.bankFavourite = MyContainer:New("BankFavourite", {Columns = bankWidth, Parent = f.bank})
		f.bankFavourite:SetFilter(filters.bankFavourite, true)

		f.bankAzeriteItem = MyContainer:New("BankAzeriteItem", {Columns = bankWidth, Parent = f.bank})
		f.bankAzeriteItem:SetFilter(filters.bankAzeriteItem, true)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = bankWidth, Parent = f.bank})
		f.bankLegendary:SetFilter(filters.bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = bankWidth, Parent = f.bank})
		f.bankEquipment:SetFilter(filters.bankEquipment, true)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = bankWidth, Parent = f.bank})
		f.bankConsumble:SetFilter(filters.bankConsumble, true)

		f.bankCompanion = MyContainer:New("BankCompanion", {Columns = bankWidth, Parent = f.bank})
		f.bankCompanion:SetFilter(filters.bankMountPet, true)

		f.bankGoods = MyContainer:New("BankGoods", {Columns = bankWidth, Parent = f.bank})
		f.bankGoods:SetFilter(filters.bankGoods, true)

		f.reagent = MyContainer:New("Reagent", {Columns = bankWidth})
		f.reagent:SetFilter(filters.onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()

		module.BagGroup = {f.azeriteItem, f.equipment, f.bagCompanion, f.bagGoods, f.consumble, f.bagFavourite, f.junk}
		module.BankGroup = {f.bankAzeriteItem, f.bankEquipment, f.bankLegendary, f.bankCompanion, f.bankGoods, f.bankConsumble, f.bankFavourite}
	end

	local initBagType
	function Backpack:OnBankOpened()
		BankFrame:Show()
		self:GetContainer("Bank"):Show()

		if not initBagType then
			module:UpdateAllBags() -- Initialize bagType
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		BankFrame.selectedTab = 1
		BankFrame:Hide()
		self:GetContainer("Bank"):Hide()
		self:GetContainer("Reagent"):Hide()
		ReagentBankFrame:Hide()
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
		self.Count:SetFont(unpack(DB.Font))
		self.Cooldown:SetInside()

		B.CreateBD(self, .3)
		self:SetBackdropColor(.3, .3, .3, .3)

		self.Azerite = self:CreateTexture(nil, "ARTWORK")
		self.Azerite:SetAtlas("AzeriteIconFrame")
		self.Azerite:SetInside()

		self.Corrupt = self:CreateTexture(nil, "ARTWORK")
		self.Corrupt:SetAtlas("Nzoth-inventory-icon")
		self.Corrupt:SetInside()

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		self.junkIcon = parentFrame:CreateTexture(nil, "ARTWORK")
		self.junkIcon:SetAtlas("bags-junkcoin")
		self.junkIcon:SetSize(20, 20)
		self.junkIcon:SetPoint("TOPRIGHT", 1, 0)

		self.Favourite = parentFrame:CreateTexture(nil, "ARTWORK")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(30, 30)
		self.Favourite:SetPoint("TOPLEFT", -12, 9)

		self.Quest = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)
		self.iLvl = B.CreateFS(self, 12, "", false, "BOTTOMLEFT", 1, 2)

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
		[0] = {.3, .3, .3, .3},	-- 容器
		[1] = false,				-- 弹药袋
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
		return item.link and item.level and item.rarity > 1 and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.junkIcon:SetAlpha(1)
		else
			self.junkIcon:SetAlpha(0)
		end

		if item.link and C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) then
			self.Azerite:SetAlpha(1)
		else
			self.Azerite:SetAlpha(0)
		end

		if item.link and IsCorruptedItem(item.link) then
			self.Corrupt:SetAlpha(1)
		else
			self.Corrupt:SetAlpha(0)
		end

		if NDuiDB["Bags"]["FavouriteItems"][item.id] then
			self.Favourite:SetAlpha(1)
		else
			self.Favourite:SetAlpha(0)
		end

		if NDuiDB["Bags"]["BagsiLvl"] and isItemNeedsLevel(item) then
			local level = B.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
			if level < NDuiDB["Bags"]["iLvlToShow"] then level = "" end
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		else
			self.iLvl:SetText("")
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) then
				B.ShowOverlayGlow(self.glowFrame)
			else
				B.HideOverlayGlow(self.glowFrame)
			end
		end

		if NDuiDB["Bags"]["SpecialBagsColor"] then
			local bagType = module.BagsType[item.bagID]
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self:SetBackdropColor(unpack(color))
		else
			self:SetBackdropColor(.3, .3, .3, .3)
		end
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.Quest:SetAlpha(1)
		else
			self.Quest:SetAlpha(0)
		end

		if item.questID or item.isQuestItem then
			self:SetBackdropBorderColor(.8, .8, 0)
		elseif item.rarity and item.rarity > -1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local MyContainer = Backpack:GetContainerClass()

	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local columns = self.Settings.Columns
		local offset = 38
		local spacing = 3
		local xOffset = 5
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize+spacing)-spacing
		if self.freeSlot then
			if NDuiDB["Bags"]["GatherEmpty"] then
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

		module:UpdateAnchors(f.main, module.BagGroup)
		module:UpdateAnchors(f.bank, module.BankGroup)
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		B.SetBD(self)
		B.CreateMF(self, settings.Parent, true)

		local label
		if strmatch(name, "AzeriteItem$") then
			label = L["Azerite Armor"]
		elseif strmatch(name, "Equipment$") then
			if itemSetFilter then
				label = L["Equipement Set"]
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif strmatch(name, "Companion") then
			label = MOUNTS_AND_PETS
		elseif strmatch(name, "Favourite") then
			label = PREFERENCES
		elseif strmatch(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		end
		if label then
			self.label = B.CreateFS(self, 14, label, true, "TOPLEFT", 5, -8)
			return
		end

		module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = module.CreateCloseButton(self)
		if name == "Main" then
			module.CreateBagBar(self, settings, 4)
			buttons[2] = module.CreateRestoreButton(self, f)
			buttons[3] = module.CreateBagToggle(self)
			buttons[5] = module.CreateSplitButton(self)
			buttons[6] = module.CreateFavouriteButton(self)
			if deleteButton then buttons[7] = module.CreateDeleteButton(self) end
		elseif name == "Bank" then
			module.CreateBagBar(self, settings, 7)
			buttons[2] = module.CreateReagentButton(self, f)
			buttons[3] = module.CreateBagToggle(self)
		elseif name == "Reagent" then
			buttons[2] = module.CreateBankButton(self, f)
			buttons[3] = module.CreateDepositButton(self)
		end
		buttons[4] = module.CreateSortButton(self, name)

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -5, -3)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -3, 0)
			end
		end

		self:HookScript("OnShow", B.RestoreMF)

		self.iconSize = iconSize
		module.CreateFreeSlots(self)
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
		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if not self.hidden and not self.notBought then
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor(0, 0, 0)
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			module.BagsType[self.bagID] = subClassID or 0
		else
			module.BagsType[self.bagID] = 0
		end
	end

	-- Fixes
	ToggleAllBags()
	ToggleAllBags()
	module.initComplete = true

	BankFrame.GetRight = function() return f.bank:GetRight() end
	BankFrameItemButton_Update = B.Dummy

	-- Sort order
	SetSortBagsRightToLeft(not NDuiDB["Bags"]["ReverseSort"])
	SetInsertItemsLeftToRight(false)

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