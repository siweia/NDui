local B, C, L, DB = unpack(select(2, ...))
local module = NDui:RegisterModule("Misc")

--[[
	Miscellaneous 各种有用没用的小玩意儿
]]
-- Add elements
function module:OnLogin()
	self:SoloInfo()
	self:RareAlert()
	self:InterruptAlert()
	self:Expbar()
	self:Focuser()
	self:Mailbox()
	self:MissingStats()
	self:ShowItemLevel()
	self:BeamTool()
	self:ReflectingAlert()
	self:SwapingAlert()

	-- Hide Bossbanner
	if NDuiDB["Misc"]["HideBanner"] then
		BossBanner:UnregisterAllEvents()
	end
end

-- Archaeology counts
local function CalculateArches()
	print("|cff0080ff【NDui】".."|c0000FF00"..L["Arch Count"]..":")
	local ta = 0
	for x = 1, 15 do
		local c = GetNumArtifactsByRace(x)
		local a = 0
		for y = 1, c do
			local t = select(9, GetArtifactInfoByRace(x, y))
			a = a + t
		end
		local rn = GetArchaeologyRaceInfo(x)
		if (c > 1) then
			print("     - |cfffed100"..rn..": ".."|cff70C0F5"..a)
			ta = ta + a
		end 
	end
	print("    -> |c0000ff00"..TOTAL..": ".."|cffff0000"..ta)
	print("|cff70C0F5------------------------")
end
local function AddCalculateIcon()
	local ar = CreateFrame("Button", nil, ArchaeologyFrameCompletedPage)
	ar:SetPoint("TOPRIGHT", -45, -45)
	ar:SetSize(35, 35)
	B.CreateIF(ar, true)
	ar.Icon:SetTexture("Interface\\ICONS\\Ability_Iyyokuk_Calculate")
	B.CreateGT(ar, "ANCHOR_RIGHT", L["Arch Count"], "system")
	ar:SetScript("OnMouseUp", CalculateArches)
end
NDui:EventFrame("ADDON_LOADED"):SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_ArchaeologyUI" then
		AddCalculateIcon()
		-- Repoint Bar
		ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
		ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 150)
		B.CreateMF(ArcheologyDigsiteProgressBar)

		self:UnregisterAllEvents()
	end
end)

-- Artifact Power Calculate
SlashCmdList["NDUI_ARTI_CALCULATOR"] = function(arg)
	if not HasArtifactEquipped() then return end
	local total, low, high = 0, 1, 0
	if arg == "" then
		print(DB.InfoColor.."------------------------")
		print(L["ArtiCal Help"])
		print("/arc total "..DB.InfoColor..L["ArtiCal TotalCount"])
		print("/arc 23 "..DB.InfoColor..L["ArtiCal LevelNumb"])
		print("/arc 10-25 "..DB.InfoColor..L["ArtiCal LevelCount"])
		print(DB.InfoColor.."------------------------")
		return
	elseif strlower(arg) == strlower("total") then
		local _, _, _, _, totalXP, pointsSpent = C_ArtifactUI.GetEquippedArtifactInfo()
		total, high = totalXP, pointsSpent
	elseif string.find(arg, "-") then
		low, high = string.split("-", arg)
		low = low + 1
	elseif tonumber(arg) then
		low, high = arg, arg
	else
		return
	end
	local artifactTier = select(13, C_ArtifactUI.GetEquippedArtifactInfo())
	for i = low-1, high-1 do
		total = total + C_ArtifactUI.GetCostForPointAtRank(i, artifactTier)
	end
	print(DB.InfoColor.."------------------------")
	print(ARTIFACT_POWER, DB.InfoColor..total)
	print(DB.InfoColor.."------------------------")
end
SLASH_NDUI_ARTI_CALCULATOR1 = "/arc"

-- Hide errors in combat
local erList = {
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_OUT_OF_ENERGY] = true,
	[ERR_OUT_OF_FOCUS] = true,
	[ERR_OUT_OF_HEALTH] = true,
	[ERR_OUT_OF_MANA] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[ERR_OUT_OF_RUNES] = true,
	[ERR_OUT_OF_HOLY_POWER] = true,
	[ERR_OUT_OF_RUNIC_POWER] = true,
	[ERR_OUT_OF_SOUL_SHARDS] = true,
	[ERR_OUT_OF_ARCANE_CHARGES] = true,
	[ERR_OUT_OF_COMBO_POINTS] = true,
	[ERR_OUT_OF_CHI] = true,
	[ERR_OUT_OF_POWER_DISPLAY] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
	[SPELL_FAILED_BAD_TARGETS] = true,
	[SPELL_FAILED_CASTER_AURASTATE] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_TARGET_AURASTATE] = true,
	[ERR_NO_ATTACK_TARGET] = true,
}
NDui:EventFrame("UI_ERROR_MESSAGE"):SetScript("OnEvent", function(self, event, _, error)
	if not NDuiDB["Misc"]["HideErrors"] then return end
	if InCombatLockdown() and erList[error] then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
	end
end)

-- Show BID and highlight price
hooksecurefunc("AuctionFrame_LoadUI", function()
	if AuctionFrameBrowse_Update then
		hooksecurefunc("AuctionFrameBrowse_Update", function()
			local numBatchAuctions = GetNumAuctionItems("list")
			local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
			for i = 1, NUM_BROWSE_TO_DISPLAY do
				local index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
				if index <= numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page) then
					local name, _, count, _, _, _, _, _, _, buyoutPrice, bidAmount =  GetAuctionItemInfo("list", offset + i)
					local alpha = .5
					local color = "yellow"
					if name then
						local itemName = _G["BrowseButton"..i.."Name"]
						local moneyFrame = _G["BrowseButton"..i.."MoneyFrame"]
						local buyoutMoney = _G["BrowseButton"..i.."BuyoutFrameMoney"]
						if (buyoutPrice/10000) >= 5000 then color = "red" end
						if bidAmount > 0 then
							name = name .. " |cffffff00"..BID.."|r"
							alpha = 1.0
						end
						itemName:SetText(name)
						moneyFrame:SetAlpha(alpha)
						SetMoneyFrameColor(buyoutMoney:GetName(), color)
					end
				end
			end
		end)
	end
end)

-- Drag AltPowerbar
do
	local bar = _G.PlayerPowerBarAlt
	local mover = CreateFrame("Frame", "NDuiAltBarMover", bar)
	mover:SetPoint("CENTER", UIParent, 0, -200)
	mover:SetSize(20, 20)
	B.CreateMF(bar, mover)
	hooksecurefunc(bar, "SetPoint", function(_, _, parent)
		if parent ~= mover then
			bar:ClearAllPoints()
			bar:SetPoint("CENTER", mover)
		end
	end)
	hooksecurefunc("UnitPowerBarAlt_SetUp", function(self)
		local statusFrame = self.statusFrame
		if statusFrame.enabled then
			statusFrame:Show()
			statusFrame.Hide = statusFrame.Show
		end
	end)
end

-- Autoequip in Spec-changing
NDui:EventFrame("UNIT_SPELLCAST_SUCCEEDED"):SetScript("OnEvent", function(self, event, ...)
	if not NDuiDB["Misc"]["Autoequip"] then
		self:UnregisterAllEvents()
		return
	end

	local unit, _, _, _, spellID = ...
	if unit ~= "player" or spellID ~= 200749 then return end
	local _, _, id = GetInstanceInfo()
	if id == 8 then return end

	if not GetSpecialization() then return end
	local _, name = GetSpecializationInfo(GetSpecialization())
	local setID = C_EquipmentSet.GetEquipmentSetID(name)
	if name and setID then
		local _, _, _, hasEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
		if not hasEquipped then
			C_EquipmentSet.UseEquipmentSet(setID)
			print(format(DB.InfoColor..EQUIPMENT_SETS, name))
		end
	else
		for i = 1, GetNumEquipmentSets() do
			local name, _, _, isEquipped = GetEquipmentSetInfo(i)
			if isEquipped then
				print(format(DB.InfoColor..EQUIPMENT_SETS, name))
				break
			end
		end
	end
end)

-- Get Naked
do
	local CharacterFrameInsetRight, PaperDollSidebarTab1 = _G.CharacterFrameInsetRight, _G.PaperDollSidebarTab1
	local EquipmentManager_UnequipItemInSlot, EquipmentManager_RunAction = _G.EquipmentManager_UnequipItemInSlot, _G.EquipmentManager_RunAction
	local bu = CreateFrame("Button", nil, CharacterFrameInsetRight)
	bu:SetSize(29, 30)
	bu:SetPoint("RIGHT", PaperDollSidebarTab1, "LEFT", -4, -2)
	B.CreateIF(bu, true)
	bu.Icon:SetTexture("Interface\\ICONS\\SPELL_SHADOW_TWISTEDFAITH")
	B.CreateGT(bu, "ANCHOR_RIGHT", L["Get Naked"])

	local function UnequipItemInSlot(i)
		local action = EquipmentManager_UnequipItemInSlot(i)
		EquipmentManager_RunAction(action)
	end
	bu:SetScript("OnDoubleClick", function()
		for i = 1, 17 do
			local texture = GetInventoryItemTexture("player", i)
			if texture then
				UnequipItemInSlot(i) 
			end
		end
	end)
end

-- ALT+RightClick to buy a stack
local old_MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
local cache = {}
function MerchantItemButton_OnModifiedClick(self, ...)
	if IsAltKeyDown() then
		local id = self:GetID()
		local itemLink = GetMerchantItemLink(id)
		if not itemLink then return end
		local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
		if ( maxStack and maxStack > 1 ) then
			if not cache[itemLink] then
				StaticPopupDialogs["BUY_STACK"] = {
					text = L["Stack Buying Check"],
					button1 = YES,
					button2 = NO,
					OnAccept = function()
						BuyMerchantItem(id, GetMerchantItemMaxStack(id))
						cache[itemLink] = true
					end,
					hideOnEscape = 1,
					hasItemFrame = 1,
				}
				local r, g, b = GetItemQualityColor(quality or 1)
				StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
			else
				BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			end
		end
	end
	old_MerchantItemButton_OnModifiedClick(self, ...)
end

-- Auto screenshot when achieved
local function TakeScreen(delay, func, ...)
	local waitTable = {}
	local waitFrame = _G["TakeScreenWaitFrame"] or CreateFrame("Frame", "TakeScreenWaitFrame", UIParent)
	waitFrame:SetScript("OnUpdate", function(self, elapse)
		local count = #waitTable
		local i = 1
		while (i <= count) do
			local waitRecord = tremove(waitTable, i)
			local d = tremove(waitRecord, 1)
			local f = tremove(waitRecord, 1)
			local p = tremove(waitRecord, 1)
			if (d > elapse) then
				tinsert(waitTable, i, {d-elapse, f, p})
				i = i + 1
			else
				count = count - 1
				f(unpack(p))
			end
		end
	end)
	tinsert(waitTable, {delay, func, {...}})
end
NDui:EventFrame("ACHIEVEMENT_EARNED"):SetScript("OnEvent", function()
	if not NDuiDB["Misc"]["Screenshot"] then return end
	TakeScreen(1, Screenshot)
end)

-- RC in MasterSound
NDui:EventFrame("READY_CHECK"):SetScript("OnEvent", function()
	PlaySound("ReadyCheck", "master")
end)

-- Faster Looting
local tDelay = 0
local function FastLoot()
	if not NDuiDB["Misc"]["FasterLoot"] then return end
	if GetTime() - tDelay >= .3 then
		tDelay = GetTime()
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			tDelay = GetTime()
		end
	end
end
NDui:EventFrame("LOOT_READY"):SetScript("OnEvent", FastLoot)

-- Hide TalkingFrame
local function NoTalkingHeads(self)
	hooksecurefunc(TalkingHeadFrame, "Show", function(self)
		self:Hide()
	end)
	TalkingHeadFrame.ignoreFramePositionManager = true
	self:UnregisterAllEvents()
end
NDui:EventFrame({"ADDON_LOADED", "PLAYER_ENTERING_WORLD"}):SetScript("OnEvent", function(self, event, addon)
	if not NDuiDB["Misc"]["HideTalking"] then
		self:UnregisterAllEvents()
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			NoTalkingHeads(self)
		end
	elseif event == "ADDON_LOADED" and addon == "Blizzard_TalkingHeadUI" then
		NoTalkingHeads(self)
	end
end)

-- Extend Instance
do
	local RaidInfoFrame = _G.RaidInfoFrame
	local bu = CreateFrame("Button", nil, RaidInfoFrame)
	bu:SetPoint("TOPRIGHT", -35, -5)
	bu:SetSize(25, 25)
	B.CreateIF(bu, true)
	bu.Icon:SetTexture(GetSpellTexture(80353))
	B.CreateGT(bu, "ANCHOR_RIGHT", L["Extend Instance"], "system")

	bu:SetScript("OnMouseUp", function(_, btn)
		for i = 1, GetNumSavedInstances() do
			local _, _, _, _, _, extended, _, isRaid = GetSavedInstanceInfo(i)
			if isRaid then
				if btn == "LeftButton" then
					if not extended then
						SetSavedInstanceExtend(i, true)		-- extend
					end
				else
					if extended then
						SetSavedInstanceExtend(i, false)	-- cancel
					end
				end
			end
		end
		RequestRaidInfo()
		RaidInfoFrame_Update()
	end)
end

-- Repoint Vehicle
do
	local indicator = _G.VehicleSeatIndicator
	local mover = CreateFrame("Button", "NDuiVehicleSeatMover", indicator)
	mover:SetPoint("BOTTOMRIGHT", UIParent, -360, 30)
	mover:SetSize(22, 22)
	mover:SetFrameStrata("HIGH")
	mover.Icon = mover:CreateTexture(nil, "ARTWORK")
	mover.Icon:SetAllPoints()
	mover.Icon:SetTexture(DB.gearTex)
	mover.Icon:SetTexCoord(0, .5, 0, .5)
	mover:SetHighlightTexture(DB.gearTex)
	mover:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)
	B.CreateGT(mover, "ANCHOR_TOP", L["Toggle"], "system")
	B.CreateMF(mover)

	hooksecurefunc(indicator, "SetPoint", function(_, _, parent)
		if parent ~= mover then
			indicator:ClearAllPoints()
			indicator:SetClampedToScreen(true)
			indicator:SetPoint("BOTTOMRIGHT", mover, "BOTTOMLEFT", -5, 0)
		end
	end)
end

-- Fix Drag Collections taint
NDui:EventFrame("ADDON_LOADED"):SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
		CollectionsJournal:HookScript("OnShow", function()
			if not self.init then
				if InCombatLockdown() then
					self:RegisterEvent("PLAYER_REGEN_ENABLED")
				else
					B.CreateMF(CollectionsJournal)
					self:UnregisterAllEvents()
				end
				self.init = true
			end
		end)
	elseif event == "PLAYER_REGEN_ENABLED" then
		B.CreateMF(CollectionsJournal)
		self:UnregisterAllEvents()
	end
end)

-- Temporary PVP queue taint fix
InterfaceOptionsFrameCancel:SetScript("OnClick", function()
    InterfaceOptionsFrameOkay:Click()
end)