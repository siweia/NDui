local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("Bags")
local cargBags = NDui.cargBags

function module:OnLogin()
	if not NDuiDB["Bags"]["Enable"] then return end

	local Backpack = cargBags:NewImplementation("NDui_Backpack")
	Backpack:RegisterBlizzard()

	local f = {}
	function Backpack:OnInit()
		-- Item Filter
		local function isItemInBag(item)
			return item.bagID >= 0 and item.bagID <= 4
		end

		local function isItemInBank(item)
			return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
		end

		local function isItemArtifactPower(item)
			if not NDuiDB["Bags"]["ItemFilter"] then return end
			return IsArtifactPowerItem(item.id)
		end

		local function isItemEquipment(item)
			if not NDuiDB["Bags"]["ItemFilter"] then return end
			if NDuiDB["Bags"]["ItemSetFilter"] then
				return item.isInSet
			else
				return item.level and item.rarity > 1 and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.equipLoc ~= "")
			end
		end

		local function isItemConsumble(item)
			if not NDuiDB["Bags"]["ItemFilter"] then return end
			return item.type == AUCTION_CATEGORY_CONSUMABLES and item.rarity > LE_ITEM_QUALITY_POOR or item.type == AUCTION_CATEGORY_ITEM_ENHANCEMENT
		end

		local onlyBags = function(item) return isItemInBag(item) and not isItemArtifactPower(item) and not isItemEquipment(item) and not isItemConsumble(item) end
		local bagArtifactPower = function(item) return isItemInBag(item) and isItemArtifactPower(item) end
		local bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
		local bagConsumble = function(item) return isItemInBag(item) and isItemConsumble(item) end
		local onlyBank = function(item) return isItemInBank(item) and not isItemArtifactPower(item) and not isItemEquipment(item) and not isItemConsumble(item) end
		local bankArtifactPower = function(item) return isItemInBank(item) and isItemArtifactPower(item) end
		local bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
		local bankConsumble = function(item) return isItemInBank(item) and isItemConsumble(item) end
		local onlyReagent = function(item) return item.bagID == -3 end

		-- Backpack Init
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -100, 150)

		f.artifactPower = MyContainer:New("ArtifactPower", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "artifactpower"})
		f.artifactPower:SetFilter(bagArtifactPower, true)

		f.consumble = MyContainer:New("Consumble", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "consumble"})
		f.consumble:SetFilter(bagConsumble, true)

		f.equipment = MyContainer:New("Equipment", {Columns = NDuiDB["Bags"]["BagsWidth"], Bags = "equipment"})
		f.equipment:SetFilter(bagEquipment, true)

		f.bank = MyContainer:New("Bank", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -20, 0)
		f.bank:Hide()

		f.reagent = MyContainer:New("Reagent", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankreagent"})
		f.reagent:SetFilter(onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()

		f.bankArtifactPower = MyContainer:New("BankArtifactPower", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankartifactpower"})
		f.bankArtifactPower:SetFilter(bankArtifactPower, true)
		f.bankArtifactPower:SetParent(f.bank)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankconsumble"})
		f.bankConsumble:SetFilter(bankConsumble, true)
		f.bankConsumble:SetParent(f.bank)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = NDuiDB["Bags"]["BankWidth"], Bags = "bankequipment"})
		f.bankEquipment:SetFilter(bankEquipment, true)
		f.bankEquipment:SetParent(f.bank)
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
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFont(unpack(DB.Font))

		self.BG = B.CreateBG(self, 1.2)
		self.BG:SetBackdrop({
			bgFile = DB.bdTex, edgeFile = DB.bdTex, edgeSize = 1.2,
		})
		self.BG:SetBackdropColor(0, 0, 0, .3)
		self.BG:SetBackdropBorderColor(0, 0, 0)

		self.Junk = self:CreateTexture(nil, "ARTWORK")
		self.Junk:SetAtlas("bags-junkcoin")
		self.Junk:SetSize(20, 20)
		self.Junk:SetPoint("TOPRIGHT", 1, 0)

		self.Quest = B.CreateFS(self, 30, "!", false, "LEFT", 3, 0)
		self.Quest:SetTextColor(1, .8, 0)

		if NDuiDB["Bags"]["Artifact"] then
			self.Artifact = self:CreateTexture(nil, "ARTWORK")
			self.Artifact:SetAtlas("collections-icon-favorites")
			self.Artifact:SetSize(35, 35)
			self.Artifact:SetPoint("TOPLEFT", -12, 10)
		end

		if NDuiDB["Bags"]["BagsiLvl"] then
			self.iLvl = B.CreateFS(self, 12, "", false, "BOTTOMLEFT", 1, 1)
		end

		if NDuiDB["Bags"]["NewItemGlow"] then
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
		end

		if NDuiDB["Bags"]["PreferPower"] > 1 then
			local protect = self:CreateTexture(nil, "ARTWORK")
			protect:SetTexture("Interface\\PETBATTLES\\DeadPetIcon")
			protect:SetAllPoints()
			protect:SetAlpha(0)

			self.powerProtect = protect
		end
	end

	local function isPowerInWrongSpec()
		if NDuiDB["Bags"]["PreferPower"] == 1 then return end
		local spec = GetSpecialization()
		if spec and spec + 1 ~= NDuiDB["Bags"]["PreferPower"] then
			return true
		end
	end

	local itemLevelString = _G["ITEM_LEVEL"]:gsub("%%d", "")
	local ItemDB = {}
	local function GetBagItemLevel(link, bag, slot)
		if ItemDB[link] then return ItemDB[link] end

		local tip = _G["NDuiBagItemTooltip"] or CreateFrame("GameTooltip", "NDuiBagItemTooltip", nil, "GameTooltipTemplate")
		tip:SetOwner(UIParent, "ANCHOR_NONE")
		tip:SetBagItem(bag, slot)

		for i = 2, 5 do
			local text = _G[tip:GetName().."TextLeft"..i]:GetText() or ""
			local hasLevel = string.find(text, itemLevelString)
			if hasLevel then
				local level = string.match(text, "(%d+)%)?$")
				ItemDB[link] = tonumber(level)
				break
			end
		end
		return ItemDB[link]
	end

	function MyButton:OnUpdate(item)
		self.Junk:SetAlpha(0)
		if item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 and MerchantFrame:IsShown() then
			self.Junk:SetAlpha(1)
		end

		self.ShowNewItems = NDuiDB["Bags"]["NewItemGlow"]

		if NDuiDB["Bags"]["Artifact"] then
			self.Artifact:SetAlpha(0)
			if item.rarity == LE_ITEM_QUALITY_ARTIFACT or item.id == 138019 then
				self.Artifact:SetAlpha(1)
			end
		end

		if NDuiDB["Bags"]["BagsiLvl"] then
			self.iLvl:SetText("")
			if item.link and item.level and item.rarity > 1 and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or (item.equipLoc ~= "" and item.equipLoc ~= "INVTYPE_TABARD" and item.equipLoc ~= "INVTYPE_BODY")) then
				local level = GetBagItemLevel(item.link, item.bagID, item.slotID) or item.level
				local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			end
		end

		if self.powerProtect then
			if isPowerInWrongSpec() and IsArtifactPowerItem(item.id) then
				self.powerProtect:SetAlpha(1)
			else
				self.powerProtect:SetAlpha(0)
			end
		end
	end

	function MyButton:OnUpdateQuest(item)
		self.Quest:SetAlpha(0)
		if item.questID and not item.questActive then self.Quest:SetAlpha(1) end

		if item.questID or item.isQuestItem then
			self.BG:SetBackdropBorderColor(.8, .8, 0)
		elseif item.rarity and item.rarity > 1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self.BG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self.BG:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
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

		local offset = -35
		if self.name == "Main" or self.name == "Bank" or self.name == "Reagent" then offset = -10 end

		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 7, 10, offset)
		self:SetSize(width + 20, height + 45)

		local anchor = f.main
		for _, bag in ipairs({f.artifactPower, f.equipment, f.consumble}) do
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
		for _, bag in ipairs({f.bankArtifactPower, f.bankEquipment, f.bankConsumble}) do
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
		B.CreateBD(self, .5, 1)
		B.CreateSD(self, 2, 3)
		B.CreateTex(self)

		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:SetScale(NDuiDB["Bags"]["BagsScale"])

		if name == "Main" or name == "Bank" or name == "Reagent" then
			B.CreateMF(self)
		else
			B.CreateMF(self, f.main)
		end

		if name == "ArtifactPower" or name == "BankArtifactPower" then
			B.CreateFS(self, 14, ARTIFACT_POWER, true, "TOPLEFT", 8, -8)
			return
		elseif name == "Equipment" or name == "BankEquipment" then
			if NDuiDB["Bags"]["ItemSetFilter"] then
				B.CreateFS(self, 14, L["Equipement Set"], true, "TOPLEFT", 8, -8)
			else
				B.CreateFS(self, 14, BAG_FILTER_EQUIPMENT, true, "TOPLEFT", 8, -8)
			end
			return
		elseif name == "Consumble" or name == "BankConsumble" then
			B.CreateFS(self, 14, BAG_FILTER_CONSUMABLES, true, "TOPLEFT", 8, -8)
			return
		end

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
		B.CreateBD(sbg, .5, 1)

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
			bagBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 8, -12)
			local bg = CreateFrame("Frame", nil, bagBar)
			bg:SetPoint("TOPLEFT", -10, 10)
			bg:SetPoint("BOTTOMRIGHT", -115, -10)
			B.CreateBD(bg)
			B.CreateTex(bg)

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
				switch:SetScript("OnClick", function(self, button)
					if not IsReagentBankUnlocked() then
						StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
					else
						PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
						ReagentBankFrame:Show()
						BankFrame.selectedTab = 2
						f.reagent:Show()
						f.bank:Hide()
						if button == "RightButton" then
							DepositReagentBank()
						end
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
	local function getRightFix() return f.bank:GetRight() end
	BankFrame.GetRight = getRightFix

	-- Cleanup Bags Order
	SetSortBagsRightToLeft(not NDuiDB["Bags"]["ReverseSort"])
	SetInsertItemsLeftToRight(false)
end