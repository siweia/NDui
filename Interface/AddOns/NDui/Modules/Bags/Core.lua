local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Bags")
local cargBags = ns.cargBags

function module:OnLogin()
	if not NDuiDB["Bags"]["Enable"] then return end
	if IsAddOnLoaded("AuroraClassic") then
		AuroraOptionsbags:SetAlpha(0)
		AuroraOptionsbags:Disable()
		AuroraConfig.bags = false
	end

	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()

	local f = {}
	local onlyBags, bagAzeriteItem, bagEquipment, bagConsumble, onlyBank, bankAzeriteItem, bankLegendary, bankEquipment, bankConsumble, onlyReagent = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -100, 150)

		f.azeriteItem = MyContainer:New("AzeriteItem", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "azeriteitem"})
		f.azeriteItem:SetFilter(bagAzeriteItem, true)
		f.azeriteItem:SetParent(f.main)

		f.equipment = MyContainer:New("Equipment", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "equipment"})
		f.equipment:SetFilter(bagEquipment, true)
		f.equipment:SetParent(f.main)

		f.consumble = MyContainer:New("Consumble", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "consumble"})
		f.consumble:SetFilter(bagConsumble, true)
		f.consumble:SetParent(f.main)

		f.bank = MyContainer:New("Bank", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -20, 0)
		f.bank:Hide()

		f.bankAzeriteItem = MyContainer:New("BankAzeriteItem", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankazeriteitem"})
		f.bankAzeriteItem:SetFilter(bankAzeriteItem, true)
		f.bankAzeriteItem:SetParent(f.bank)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "banklegendary"})
		f.bankLegendary:SetFilter(bankLegendary, true)
		f.bankLegendary:SetParent(f.bank)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankequipment"})
		f.bankEquipment:SetFilter(bankEquipment, true)
		f.bankEquipment:SetParent(f.bank)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankconsumble"})
		f.bankConsumble:SetFilter(bankConsumble, true)
		f.bankConsumble:SetParent(f.bank)

		f.reagent = MyContainer:New("Reagent", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankreagent"})
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

		self.Junk = self:CreateTexture(nil, "ARTWORK")
		self.Junk:SetAtlas("bags-junkcoin")
		self.Junk:SetSize(20, 20)
		self.Junk:SetPoint("TOPRIGHT", 1, 0)

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

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.Junk:SetAlpha(1)
		else
			self.Junk:SetAlpha(0)
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

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		self:SetPushedTexture(nil)
		self:SetCheckedTexture(DB.textures.pushed)
		self:GetCheckedTexture():SetVertexColor(.3, .9, .9, .5)

		self.Icon:SetPoint("TOPLEFT", 2, -2)
		self.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
	end

	local MyContainer = Backpack:GetContainerClass()
	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local offset = -32
		if self.name == "Main" or self.name == "Bank" or self.name == "Reagent" then offset = -10 end

		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 5, 10, offset)
		self:SetSize(width + 20, height + 45)

		local anchor = f.main
		for _, bag in ipairs({f.azeriteItem, f.equipment, f.consumble}) do
			if bag:GetHeight() > 45 then
				bag:Show()
			else
				bag:Hide()
			end
			if bag:IsShown() then
				bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 3)
				anchor = bag
			end
		end

		local bankAnchor = f.bank
		for _, bag in ipairs({f.bankAzeriteItem, f.bankEquipment, f.bankLegendary, f.bankConsumble}) do
			if bag:GetHeight() > 45 then
				bag:Show()
			else
				bag:Hide()
			end
			if bag:IsShown() then
				bag:SetPoint("BOTTOMLEFT", bankAnchor, "TOPLEFT", 0, 3)
				bankAnchor = bag
			end
		end
	end

	local function ReverseSort()
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

	local function highlightFunction(button, match)
		button:SetAlpha(match and 1 or .3)
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		if IsAddOnLoaded("AuroraClassic") then
			local F = unpack(AuroraClassic)
			F.SetBD(self)
		else
			B.CreateBD(self)
			B.CreateSD(self)
			B.CreateTex(self)
		end

		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)

		if name == "Main" or name == "Bank" or name == "Reagent" then
			self:SetScale(NDuiDB["Bags"]["BagsScale"])
			B.CreateMF(self)
		elseif name:match("^Bank%a+") then
			B.CreateMF(self, f.bank)
		else
			B.CreateMF(self, f.main)
		end

		local label
		if name:match("AzeriteItem$") then
			label = L["Azerite Armor"]
		elseif name:match("Equipment$") then
			if NDuiDB["Bags"]["ItemSetFilter"] then
				label = L["Equipement Set"]
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif name:match("Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		end
		if label then B.CreateFS(self, 14, label, true, "TOPLEFT", 8, -8) return end

		local infoFrame = CreateFrame("Button", nil, self)
		infoFrame:SetPoint("BOTTOMRIGHT", -50, 0)
		infoFrame:SetWidth(220)
		infoFrame:SetHeight(32)

		local search = self:SpawnPlugin("SearchBar", infoFrame)
		search.highlightFunction = highlightFunction
		search.isGlobal = true
		search:SetPoint("LEFT", infoFrame, "LEFT", 0, 5)
		search.Left:SetTexture(nil)
		search.Right:SetTexture(nil)
		search.Center:SetTexture(nil)
		local sbg = CreateFrame("Frame", nil, search)
		sbg:SetPoint("CENTER", search, "CENTER")
		sbg:SetSize(230, 22)
		sbg:SetFrameLevel(search:GetFrameLevel() - 1)
		B.CreateBD(sbg)

		local tagDisplay = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
		tagDisplay:SetFont(unpack(DB.Font))
		tagDisplay:SetPoint("RIGHT", infoFrame, "RIGHT",0,0)
		B.CreateFS(infoFrame, 14, SEARCH, true, "LEFT", 0, 1)

		local SortButton = B.CreateButton(self, 60, 20, L["Sort"])
		SortButton:SetPoint("BOTTOMLEFT", 5, 7)
		SortButton:SetScript("OnClick", function()
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
						ReverseSort()
					end
				else
					SortBags()
				end
			end
		end)

		local closebutton = B.CreateButton(self, 20, 20, "X")
		closebutton:SetPoint("BOTTOMRIGHT", -5, 7)
		closebutton:SetScript("OnClick", CloseAllBags)

		if name == "Main" or name == "Bank" then
			local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
			bagBar:SetSize(bagBar:LayoutButtons("grid", 7))
			bagBar:SetScale(.8)
			bagBar.highlightFunction = highlightFunction
			bagBar.isGlobal = true
			bagBar:Hide()
			self.BagBar = bagBar
			bagBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 8, -11)
			local bg = CreateFrame("Frame", nil, bagBar)
			bg:SetPoint("TOPLEFT", -8, 8)
			bg:SetPoint("BOTTOMRIGHT", -118, -8)
			if IsAddOnLoaded("AuroraClassic") then
				local F = unpack(AuroraClassic)
				F.SetBD(bg)
			else
				B.CreateBD(bg)
				B.CreateSD(bg)
				B.CreateTex(bg)
			end

			local bagToggle = B.CreateButton(self, 60, 20, BAGSLOT)
			bagToggle:SetPoint("LEFT", SortButton, "RIGHT", 6, 0)
			bagToggle:SetScript("OnClick", function()
				ToggleFrame(self.BagBar)
			end)

			if name == "Bank" then
				bg:SetPoint("TOPLEFT", -10, 10)
				bg:SetPoint("BOTTOMRIGHT", 10, -10)

				local switch = B.CreateButton(self, 70, 20, REAGENT_BANK)
				switch:SetPoint("LEFT", bagToggle, "RIGHT", 6, 0)
				switch:RegisterForClicks("AnyUp")
				switch:SetScript("OnClick", function(_, btn)
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
			end
		elseif name == "Reagent" then
			local deposit = B.CreateButton(self, 100, 20, REAGENTBANK_DEPOSIT)
			deposit:SetPoint("LEFT", SortButton, "RIGHT", 6, 0)
			deposit:SetScript("OnClick", DepositReagentBank)

			local switch = B.CreateButton(self, 70, 20, BANK)
			switch:SetPoint("LEFT", deposit, "RIGHT", 6, 0)
			switch:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
				ReagentBankFrame:Hide()
				BankFrame.selectedTab = 1
				f.reagent:Hide()
				f.bank:Show()
			end)
		end

		-- Add Sound
		self:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
		self:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)
	end

	-- Fix Containter Bug
	ToggleAllBags()
	ToggleAllBags()
	local function getRightFix() return f.bank:GetRight() end
	BankFrame.GetRight = getRightFix

	-- Cleanup Bags Order
	SetSortBagsRightToLeft(not NDuiDB["Bags"]["ReverseSort"])
	SetInsertItemsLeftToRight(false)
end