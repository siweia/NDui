local _, ns = ...
local B, C, L, DB = unpack(ns)

local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags
local ipairs, strmatch = ipairs, string.match

function module:ReverseSort()
	C_Timer.After(.5, function()
		for bag = 0, 4 do
			local numSlots = GetContainerNumSlots(bag)
			for slot = 1, numSlots do
				local texture, _, locked = GetContainerItemInfo(bag, slot)
				if texture and not locked then
					PickupContainerItem(bag, slot)
					PickupContainerItem(bag, numSlots+1 - slot)
				end
			end
		end
	end)
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

function module:DisableAuroraClassic()
	if not IsAddOnLoaded("AuroraClassic") then return end
	AuroraOptionsbags:SetAlpha(0)
	AuroraOptionsbags:Disable()
	AuroraConfig.bags = false
end

function module:SetBackground()
	if IsAddOnLoaded("AuroraClassic") then
		local F = unpack(AuroraClassic)
		F.SetBD(self)
	else
		B.CreateBD(self)
		B.CreateSD(self)
		B.CreateTex(self)
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

function module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(220, 32)
	B.CreateFS(infoFrame, 14, SEARCH, true, "LEFT", -5, 0)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	B.StripTextures(search)
	local bg = B.CreateBG(search)
	bg:SetPoint("TOPLEFT", -5, -5)
	bg:SetPoint("BOTTOMRIGHT", 5, 5)
	B.CreateBD(bg, .3)

	local tag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	tag:SetFont(unpack(DB.Font))
	tag:SetPoint("RIGHT", -5, 0)
end

function module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 5, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	module.SetBackground(bagBar)
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function module:CreateCloseButton()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Buttons\\UI-StopButton")
	bu:SetPoint("TOPRIGHT", -5, -5)
	bu:SetScript("OnClick", CloseAllBags)
	B.AddTooltip(bu, "ANCHOR_TOP", CLOSE)

	return bu
end

function module:CreateRestoreButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Buttons\\UI-RefreshButton")
	bu:SetScript("OnClick", function()
		NDuiDB["TempAnchor"][f.main:GetName()] = nil
		NDuiDB["TempAnchor"][f.bank:GetName()] = nil
		NDuiDB["TempAnchor"][f.reagent:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -100, 100)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.reagent:ClearAllPoints()
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", RESET)

	return bu
end

function module:CreateReagentButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS")
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
	B.AddTooltip(bu, "ANCHOR_TOP", REAGENT_BANK)

	return bu
end

function module:CreateBankButton(f)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\INV_Misc_EngGizmos_17")
	bu:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		ReagentBankFrame:Hide()
		BankFrame.selectedTab = 1
		f.reagent:Hide()
		f.bank:Show()
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", BANK)

	return bu
end

function module:CreateDepositButton()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\Spell_ChargePositive")
	bu:SetScript("OnClick", DepositReagentBank)
	B.AddTooltip(bu, "ANCHOR_TOP", REAGENTBANK_DEPOSIT)

	return bu
end

function module:CreateBagToggle()
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\INV_Misc_Bag_08")
	bu:SetScript("OnClick", function()
		ToggleFrame(self.BagBar)
		if self.BagBar:IsShown() then
			bu.Shadow:SetBackdropBorderColor(1, 1, 1)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bu.Shadow:SetBackdropBorderColor(0, 0, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", BACKPACK_TOOLTIP)

	return bu
end

function module:CreateSortButton(name)
	local bu = B.CreateButton(self, 22, 22, true, "Interface\\Icons\\INV_Pet_Broom")
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
					module:ReverseSort()
				end
			else
				SortBags()
			end
		end
	end)
	B.AddTooltip(bu, "ANCHOR_TOP", L["Sort"])

	return bu
end

function module:OnLogin()
	if not NDuiDB["Bags"]["Enable"] then return end

	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(NDuiDB["Bags"]["BagsScale"])
	Backpack:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
	Backpack:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

	local f = {}
	local onlyBags, bagAzeriteItem, bagEquipment, bagConsumble, bagsJunk, onlyBank, bankAzeriteItem, bankLegendary, bankEquipment, bankConsumble, onlyReagent = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -100, 100)

		f.junk = MyContainer:New("Junk", {Columns = NDuiDB["Bags"]["BagsWidth"], Parent = f.main})
		f.junk:SetFilter(bagsJunk, true)

		f.azeriteItem = MyContainer:New("AzeriteItem", {Columns = NDuiDB["Bags"]["BagsWidth"], Parent = f.main})
		f.azeriteItem:SetFilter(bagAzeriteItem, true)

		f.equipment = MyContainer:New("Equipment", {Columns = NDuiDB["Bags"]["BagsWidth"], Parent = f.main})
		f.equipment:SetFilter(bagEquipment, true)

		f.consumble = MyContainer:New("Consumble", {Columns = NDuiDB["Bags"]["BagsWidth"], Parent = f.main})
		f.consumble:SetFilter(bagConsumble, true)

		f.bank = MyContainer:New("Bank", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.bank:Hide()

		f.bankAzeriteItem = MyContainer:New("BankAzeriteItem", {Columns = NDuiDB["Bags"]["BankWidth"], Parent = f.bank})
		f.bankAzeriteItem:SetFilter(bankAzeriteItem, true)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = NDuiDB["Bags"]["BankWidth"], Parent = f.bank})
		f.bankLegendary:SetFilter(bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = NDuiDB["Bags"]["BankWidth"], Parent = f.bank})
		f.bankEquipment:SetFilter(bankEquipment, true)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = NDuiDB["Bags"]["BankWidth"], Parent = f.bank})
		f.bankConsumble:SetFilter(bankConsumble, true)

		f.reagent = MyContainer:New("Reagent", {Columns = NDuiDB["Bags"]["BankWidth"]})
		f.reagent:SetFilter(onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()
	end

	function Backpack:OnBankOpened()
		BankFrame:Show()
		self:GetContainer("Bank"):Show()
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

	local iconSize = NDuiDB["Bags"]["IconSize"]
	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFont(unpack(DB.Font))

		self.BG = B.CreateBG(self)
		B.CreateBD(self.BG, .3)

		self.junkIcon = self:CreateTexture(nil, "ARTWORK")
		self.junkIcon:SetAtlas("bags-junkcoin")
		self.junkIcon:SetSize(20, 20)
		self.junkIcon:SetPoint("TOPRIGHT", 1, 0)

		self.Quest = B.CreateFS(self, 30, "!", "system", "LEFT", 3, 0)

		self.Azerite = self:CreateTexture(nil, "ARTWORK")
		self.Azerite:SetAtlas("AzeriteIconFrame")
		self.Azerite:SetAllPoints()

		if NDuiDB["Bags"]["Artifact"] then
			self.Artifact = self:CreateTexture(nil, "ARTWORK")
			self.Artifact:SetAtlas("collections-icon-favorites")
			self.Artifact:SetSize(35, 35)
			self.Artifact:SetPoint("TOPLEFT", -12, 10)
		end

		if NDuiDB["Bags"]["BagsiLvl"] then
			self.iLvl = B.CreateFS(self, 12, "", false, "BOTTOMLEFT", 1, 1)
		end

		local flash = self:CreateTexture(nil, "ARTWORK")
		flash:SetTexture(DB.newItemFlash)
		flash:SetPoint("TOPLEFT", -20, 20)
		flash:SetPoint("BOTTOMRIGHT", 20, -20)
		flash:SetBlendMode("ADD")
		flash:SetAlpha(0)
		local anim = flash:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(1)
		anim.rota:SetDegrees(-90)
		anim.fader = anim:CreateAnimation("Alpha")
		anim.fader:SetFromAlpha(0)
		anim.fader:SetToAlpha(.5)
		anim.fader:SetDuration(.5)
		anim.fader:SetSmoothing("OUT")
		anim.fader2 = anim:CreateAnimation("Alpha")
		anim.fader2:SetStartDelay(.5)
		anim.fader2:SetFromAlpha(.5)
		anim.fader2:SetToAlpha(0)
		anim.fader2:SetDuration(1.2)
		anim.fader2:SetSmoothing("OUT")
		self:HookScript("OnHide", function() if anim:IsPlaying() then anim:Stop() end end)
		self.anim = anim

		self.ShowNewItems = true
	end

	function MyButton:OnEnter()
		if self.ShowNewItems then
			if self.anim:IsPlaying() then self.anim:Stop() end
		end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.junkIcon:SetAlpha(1)
		else
			self.junkIcon:SetAlpha(0)
		end

		if item.link and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
			self.Azerite:SetAlpha(1)
		else
			self.Azerite:SetAlpha(0)
		end

		if NDuiDB["Bags"]["Artifact"] then
			if item.rarity == LE_ITEM_QUALITY_ARTIFACT or item.id == 138019 then
				self.Artifact:SetAlpha(1)
			else
				self.Artifact:SetAlpha(0)
			end
		end

		if NDuiDB["Bags"]["BagsiLvl"] then
			if item.link and item.level and item.rarity > 1 and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or (item.equipLoc ~= "" and item.equipLoc ~= "INVTYPE_TABARD" and item.equipLoc ~= "INVTYPE_BODY" and item.equipLoc ~= "INVTYPE_BAG")) then
				local level = B.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
				local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				self.iLvl:SetText("")
			end
		end

		if self.ShowNewItems then
			if C_NewItems.IsNewItem(item.bagID, item.slotID) then
				self.anim:Play()
			else
				if self.anim:IsPlaying() then self.anim:Stop() end
			end
		end
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.Quest:SetAlpha(1)
		else
			self.Quest:SetAlpha(0)
		end

		if item.questID or item.isQuestItem then
			self.BG:SetBackdropBorderColor(.8, .8, 0)
		elseif item.rarity and item.rarity > -1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self.BG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.BG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local MyContainer = Backpack:GetContainerClass()
	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local offset = 38
		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 5, 5, -offset + 5)
		self:SetSize(width + 10, height + offset)

		module:UpdateAnchors(f.main, {f.azeriteItem, f.equipment, f.consumble, f.junk})
		module:UpdateAnchors(f.bank, {f.bankAzeriteItem, f.bankEquipment, f.bankLegendary, f.bankConsumble})
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		module.SetBackground(self)
		B.CreateMF(self, settings.Parent, true)

		local label
		if strmatch(name, "AzeriteItem$") then
			label = L["Azerite Armor"]
		elseif strmatch(name, "Equipment$") then
			if NDuiDB["Bags"]["ItemSetFilter"] then
				label = L["Equipement Set"]
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		elseif strmatch(name, "Junk") then
			label = BAG_FILTER_JUNK
		end
		if label then B.CreateFS(self, 14, label, true, "TOPLEFT", 5, -8) return end

		module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = module.CreateCloseButton(self)
		if name == "Main" then
			module.CreateBagBar(self, settings, 4)
			buttons[2] = module.CreateRestoreButton(self, f)
			buttons[3] = module.CreateBagToggle(self)
		elseif name == "Bank" then
			module.CreateBagBar(self, settings, 7)
			buttons[2] = module.CreateReagentButton(self, f)
			buttons[3] = module.CreateBagToggle(self)
		elseif name == "Reagent" then
			buttons[2] = module.CreateBankButton(self, f)
			buttons[3] = module.CreateDepositButton(self)
		end
		buttons[4] = module.CreateSortButton(self, name)

		for i = 1, 4 do
			local bu = buttons[i]
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -5, -5)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -5, 0)
			end
		end

		self:HookScript("OnShow", B.RestoreMF)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:SetPushedTexture(nil)
		self:SetCheckedTexture(nil)

		self:SetSize(iconSize, iconSize)
		self.BG = B.CreateBG(self)
		B.CreateBD(self.BG, 0)
		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		local quality = id and select(3, GetItemInfo(id)) or 0
		if quality == 1 then quality = 0 end
		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if self:GetChecked() then
			self.BG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.BG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	-- Fixes
	ToggleAllBags()
	ToggleAllBags()
	BankFrame.GetRight = function() return f.bank:GetRight() end

	SetSortBagsRightToLeft(not NDuiDB["Bags"]["ReverseSort"])
	SetInsertItemsLeftToRight(false)
	module:DisableAuroraClassic()
end