local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:RegisterModule("Misc")

local _G = getfenv(0)
local tonumber, strmatch = tonumber, strmatch
local InCombatLockdown, IsModifiedClick, IsAltKeyDown = InCombatLockdown, IsModifiedClick, IsAltKeyDown
local GetNumAuctionItems, GetAuctionItemInfo = GetNumAuctionItems, GetAuctionItemInfo
local FauxScrollFrame_GetOffset, SetMoneyFrameColor = FauxScrollFrame_GetOffset, SetMoneyFrameColor
local BuyMerchantItem = BuyMerchantItem
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetItemQualityColor = GetItemQualityColor
local GetTime, GetCVarBool, SetCVar = GetTime, GetCVarBool, SetCVar
local GetNumLootItems, LootSlot = GetNumLootItems, LootSlot
local GetInstanceInfo = GetInstanceInfo
local IsGuildMember, BNGetGameAccountInfoByGUID, C_FriendList_IsFriend = IsGuildMember, BNGetGameAccountInfoByGUID, C_FriendList.IsFriend
local UnitIsPlayer, GuildInvite, C_FriendList_AddFriend = UnitIsPlayer, GuildInvite, C_FriendList.AddFriend
local TakeTaxiNode, IsMounted, Dismount, C_Timer_After = TakeTaxiNode, IsMounted, Dismount, C_Timer.After
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded

--[[
	Miscellaneous 各种有用没用的小玩意儿
]]
local MISC_LIST = {}

function M:RegisterMisc(name, func)
	if not MISC_LIST[name] then
		MISC_LIST[name] = func
	end
end

function M:OnLogin()
	for name, func in next, MISC_LIST do
		if name and type(func) == "function" then
			xpcall(func, geterrorhandler())
		end
	end

	-- Init
	M:NakedIcon()
	M:VehicleSeatMover()
	M:UIWidgetFrameMover()
	M:MoveDurabilityFrame()
	M:MoveTicketStatusFrame()
	M:UpdateFasterLoot()
	M:UpdateErrorBlocker()
	M:TradeTargetInfo()
	M:BidPriceHighlight()
	M:BlockStrangerInvite()
	M:QuickMenuButton()
	M:BaudErrorFrameHelpTip()
	M:EnhancedPicker()
	C_Timer_After(0, M.UpdateMaxZoomLevel)
	M:AutoEquipBySpec()
	M:UpdateScreenShot()
	M:MoveBlizzFrames()

	-- Auto chatBubbles
	if NDuiADB["AutoBubbles"] then
		local function updateBubble()
			local name, instType = GetInstanceInfo()
			if name and instType == "raid" then
				SetCVar("chatBubbles", 1)
			else
				SetCVar("chatBubbles", 0)
			end
		end
		B:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end

	-- Readycheck sound on master channel
	B:RegisterEvent("READY_CHECK", function()
		PlaySound(SOUNDKIT.READY_CHECK, "master")
	end)

	-- Instant delete
	local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if deleteDialog.OnShow then
		hooksecurefunc(deleteDialog, "OnShow", function(self)
			if C.db["Misc"]["InstantDelete"] then
				self.EditBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end
		end)
	end

	-- Fix blizz error
	MAIN_MENU_MICRO_ALERT_PRIORITY = MAIN_MENU_MICRO_ALERT_PRIORITY or {}

	-- Fix blizz bug in addon list
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if not owner then return end
		if owner:GetID() < 1 then return end
		_AddonTooltip_Update(owner)
	end

	-- Fix MasterLooterFrame anchor issue
	hooksecurefunc(MasterLooterFrame, "Show", function(self)
		self:ClearAllPoints()
	end)

	-- Fix inspect error in wrath beta
	if not InspectTalentFrameSpentPoints then
		InspectTalentFrameSpentPoints = CreateFrame("Frame")
	end
	if not BrowseBidText then
		BrowseBidText = CreateFrame("Frame")
	end
end

-- Get Naked
function M:NakedIcon()
	local bu = CreateFrame("Button", nil, CharacterFrameInsetRight)
	bu:SetSize(33, 35)
	bu:SetPoint("RIGHT", PaperDollSidebarTab1, "LEFT", -4, 0)
	B.PixelIcon(bu, "Interface\\ICONS\\SPELL_SHADOW_TWISTEDFAITH", true)
	bu.bg:SetPoint("TOPLEFT", 2, -3)
	bu.bg:SetPoint("BOTTOMRIGHT", 0, -2)
	B.AddTooltip(bu, "ANCHOR_RIGHT", L["Get Naked"])

	local function UnequipItemInSlot(i)
		local action = EquipmentManager_UnequipItemInSlot(i)
		EquipmentManager_RunAction(action)
	end

	bu:SetScript("OnDoubleClick", function()
		for i = 1, 18 do
			local texture = GetInventoryItemTexture("player", i)
			if texture then
				UnequipItemInSlot(i)
			end
		end
	end)
end

-- Reanchor Vehicle
function M:VehicleSeatMover()
	if not VehicleSeatIndicator then return end

	local frame = CreateFrame("Frame", "NDuiVehicleSeatMover", UIParent)
	frame:SetSize(125, 125)
	B.Mover(frame, L["VehicleSeat"], "VehicleSeat", {"BOTTOMRIGHT", UIParent, -400, 30})

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame)
		end
	end)
end

-- Reanchor UIWidgetBelowMinimapContainerFrame
function M:UIWidgetFrameMover()
	local frame = CreateFrame("Frame", "NDuiUIWidgetMover", UIParent)
	frame:SetSize(200, 50)
	B.Mover(frame, L["UIWidgetFrame"], "UIWidgetFrame", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -20})

	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame)
		end
	end)
end

-- Reanchor DurabilityFrame
function M:MoveDurabilityFrame()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent ~= Minimap then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -30)
		end
	end)
end

-- Reanchor TicketStatusFrame
function M:MoveTicketStatusFrame()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Faster Looting
local lootDelay = 0
function M:DoFasterLoot()
	if GetLootMethod() == "master" then return end

	if GetTime() - lootDelay >= .3 then
		lootDelay = GetTime()
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lootDelay = GetTime()
		end
	end
end

function M:UpdateFasterLoot()
	if C.db["Misc"]["FasterLoot"] then
		B:RegisterEvent("LOOT_READY", M.DoFasterLoot)
	else
		B:UnregisterEvent("LOOT_READY", M.DoFasterLoot)
	end
end

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

local isRegistered = true
function M:ErrorBlockerOnEvent(_, text)
	if InCombatLockdown() and erList[text] then
		if isRegistered then
			UIErrorsFrame:UnregisterEvent(self)
			isRegistered = false
		end
	else
		if not isRegistered then
			UIErrorsFrame:RegisterEvent(self)
			isRegistered = true
		end
	end
end

function M:UpdateErrorBlocker()
	if C.db["Misc"]["HideErrors"] then
		B:RegisterEvent("UI_ERROR_MESSAGE", M.ErrorBlockerOnEvent)
	else
		isRegistered = true
		UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		B:UnregisterEvent("UI_ERROR_MESSAGE", M.ErrorBlockerOnEvent)
	end
end

-- TradeFrame hook
function M:TradeTargetInfo()
	local infoText = B.CreateFS(TradeFrame, 16, "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -5)

	local function updateColor()
		local r, g, b = B.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]
		if BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
			text = "|cffffff00"..FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00"..GUILD
		end
		infoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- Show BID and highlight price
function M:BidPriceHighlight()
	if IsAddOnLoaded("Auc-Advanced") then return end

	local function setupMisc(event, addon)
		if addon == "Blizzard_AuctionUI" then
			hooksecurefunc("AuctionFrameBrowse_Update", function()
				local numBatchAuctions = GetNumAuctionItems("list")
				local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
				local name, buyoutPrice, bidAmount, hasAllInfo
				for i = 1, NUM_BROWSE_TO_DISPLAY do
					local index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
					local shouldHide = index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page))
					if not shouldHide then
						name, _, _, _, _, _, _, _, _, buyoutPrice, bidAmount, _, _, _, _, _, _, hasAllInfo = GetAuctionItemInfo("list", offset + i)
						if not hasAllInfo then shouldHide = true end
					end
					if not shouldHide then
						local alpha = .5
						local color = "yellow"
						local buttonName = "BrowseButton"..i
						local itemName = _G[buttonName.."Name"]
						local moneyFrame = _G[buttonName.."MoneyFrame"]
						local buyoutMoney = _G[buttonName.."BuyoutFrameMoney"]
						if buyoutPrice >= 1e6 then color = "red" end
						if bidAmount > 0 then
							name = name.." |cffffff00"..BID.."|r"
							alpha = 1.0
						end
						itemName:SetText(name)
						moneyFrame:SetAlpha(alpha)
						SetMoneyFrameColor(buyoutMoney:GetName(), color)
					end
				end
			end)

			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- ALT+RightClick to buy a stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then return end
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = C_Item.GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Fix Drag Collections taint
do
	local done
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			CollectionsJournal:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						B.CreateMF(CollectionsJournal)
					end
					done = true
				end
			end)
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			B.CreateMF(CollectionsJournal)
			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				B:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			B:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				B:UnregisterEvent(event, setupMisc)
			end
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Buttons to enhance popup menu
function M:CustomMenu_AddFriend(rootDescription, data, name)
	rootDescription:CreateButton(DB.InfoColor..ADD_CHARACTER_FRIEND, function()
		local fullName = data.server and data.name.."-"..data.server or data.name
		C_FriendList.AddFriend(name or fullName)
	end)
end

local guildInviteString = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, "")
function M:CustomMenu_GuildInvite(rootDescription, data, name)
	rootDescription:CreateButton(DB.InfoColor..guildInviteString, function()
		local fullName = data.server and data.name.."-"..data.server or data.name
		C_GuildInfo.Invite(name or fullName)
	end)
end

function M:CustomMenu_CopyName(rootDescription, data, name)
	rootDescription:CreateButton(DB.InfoColor..COPY_NAME, function()
		local editBox = ChatEdit_ChooseBoxForSend()
		local hasText = (editBox:GetText() ~= "")
		ChatEdit_ActivateChat(editBox)
		editBox:Insert(name or data.name)
		if not hasText then editBox:HighlightText() end
	end)
end

function M:CustomMenu_Whisper(rootDescription, data)
	rootDescription:CreateButton(DB.InfoColor..WHISPER, function()
		ChatFrame_SendTell(data.name)
	end)
end

function M:QuickMenuButton()
	if not C.db["Misc"]["MenuButton"] then return end

	--hooksecurefunc(UnitPopupManager, "OpenMenu", function(_, which)
	--	print("MENU_UNIT_"..which)
	--end)

	Menu.ModifyMenu("MENU_UNIT_SELF", function(_, rootDescription, data)
		M:CustomMenu_CopyName(rootDescription, data)
		M:CustomMenu_Whisper(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_TARGET", function(_, rootDescription, data)
		M:CustomMenu_CopyName(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_PLAYER", function(_, rootDescription, data)
		M:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_FRIEND", function(_, rootDescription, data)
		M:CustomMenu_AddFriend(rootDescription, data)
		M:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_BN_FRIEND", function(_, rootDescription, data)
		local fullName
		local gameAccountInfo = data.accountInfo and data.accountInfo.gameAccountInfo
		if gameAccountInfo then
			local characterName = gameAccountInfo.characterName
			local realmName = gameAccountInfo.realmName
			if characterName and realmName then
				fullName = characterName.."-"..realmName
			end
		end
		M:CustomMenu_AddFriend(rootDescription, data, fullName)
		M:CustomMenu_GuildInvite(rootDescription, data, fullName)
		M:CustomMenu_CopyName(rootDescription, data, fullName)
	end)

	Menu.ModifyMenu("MENU_UNIT_PARTY", function(_, rootDescription, data)
		M:CustomMenu_GuildInvite(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_RAID", function(_, rootDescription, data)
		M:CustomMenu_AddFriend(rootDescription, data)
		M:CustomMenu_GuildInvite(rootDescription, data)
		M:CustomMenu_CopyName(rootDescription, data)
		M:CustomMenu_Whisper(rootDescription, data)
	end)

	Menu.ModifyMenu("MENU_UNIT_RAID_PLAYER", function(_, rootDescription, data)
		M:CustomMenu_GuildInvite(rootDescription, data)
	end)
end

-- Block invite from strangers
function M:BlockStrangerInvite()
	B:RegisterEvent("PARTY_INVITE_REQUEST", function(_, _, _, _, _, _, _, guid)
		if C.db["Misc"]["BlockInvite"] and not (IsGuildMember(guid) or BNGetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid)) then
			DeclineGroup()
			StaticPopup_Hide("PARTY_INVITE")
		end
	end)
end

function M:BaudErrorFrameHelpTip()
	if not IsAddOnLoaded("!BaudErrorFrame") then return end
	local button, count = _G.BaudErrorFrameMinimapButton, _G.BaudErrorFrameMinimapCount
	if not button then return end

	hooksecurefunc(count, "SetText", function(_, text)
		if not NDuiADB["Help"]["BaudError"] then
			text = tonumber(text)
			if text and text > 0 then
				B:ShowHelpTip(button, L["BaudErrorTip"], "TOP", -90, 15, nil, "BaudError", 80)
			end
		end
	end)
end

-- Enhanced ColorPickerFrame
local function translateColor(r)
	if not r then r = "ff" end
	return tonumber(r, 16)/255
end

function M:EnhancedPicker_UpdateColor()
	local r, g, b = strmatch(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
end

local function GetBoxColor(box)
	local r = box:GetText()
	r = tonumber(r)
	if not r or r < 0 or r > 255 then r = 255 end
	return r
end

local function updateColorRGB(self)
	local r = GetBoxColor(_G.ColorPickerFrame.__boxR)
	local g = GetBoxColor(_G.ColorPickerFrame.__boxG)
	local b = GetBoxColor(_G.ColorPickerFrame.__boxB)
	self.colorStr = format("%02x%02x%02x", r, g, b)
	M.EnhancedPicker_UpdateColor(self)
end

local function updateColorStr(self)
	self.colorStr = self:GetText()
	M.EnhancedPicker_UpdateColor(self)
end

local function createCodeBox(width, index, text)
	local box = B.CreateEditBox(_G.ColorPickerFrame, width, 22)
	box:SetMaxLetters(index == 4 and 6 or 3)
	box:SetTextInsets(0, 0, 0, 0)
	box:SetPoint("TOPLEFT", _G.ColorSwatch, "BOTTOMLEFT", 0, -index*24 + 2)
	B.CreateFS(box, 14, text, "system", "LEFT", -15, 0)
	if index == 4 then
		box:HookScript("OnEnterPressed", updateColorStr)
	else
		box:HookScript("OnEnterPressed", updateColorRGB)
	end
	return box
end

function M:EnhancedPicker()
	local pickerFrame = _G.ColorPickerFrame
	pickerFrame:SetHeight(250)
	_G.OpacitySliderFrame:SetPoint("TOPLEFT", _G.ColorSwatch, "TOPRIGHT", 50, 0)
	local mover = CreateFrame("Frame", nil, pickerFrame)
	mover:SetAllPoints(_G.ColorPickerFrameHeader)
	B.CreateMF(mover, pickerFrame) -- movable by header)

	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 22)
	colorBar:SetPoint("BOTTOM", 0, 38)

	local count = 0
	for class, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local value = DB.ClassColors[class]
		if value then
			local bu = B.CreateButton(colorBar, 22, 22, true)
			bu.Icon:SetColorTexture(value.r, value.g, value.b)
			bu:SetPoint("LEFT", count*22, 0)
			bu.colorStr = value.colorStr
			bu:SetScript("OnClick", M.EnhancedPicker_UpdateColor)
			B.AddTooltip(bu, "ANCHOR_TOP", "|c"..value.colorStr..name)

			count = count + 1
		end
	end
	colorBar:SetWidth(count*22)

	pickerFrame.__boxR = createCodeBox(45, 1, "|cffff0000R")
	pickerFrame.__boxG = createCodeBox(45, 2, "|cff00ff00G")
	pickerFrame.__boxB = createCodeBox(45, 3, "|cff0000ffB")
	pickerFrame.__boxH = createCodeBox(70, 4, "#")

	pickerFrame:HookScript("OnColorSelect", function(self)
		local r, g, b = self:GetColorRGB()
		r = B:Round(r*255)
		g = B:Round(g*255)
		b = B:Round(b*255)

		self.__boxR:SetText(r)
		self.__boxG:SetText(g)
		self.__boxB:SetText(b)
		self.__boxH:SetText(format("%02x%02x%02x", r, g, b))
	end)
end

function M:UpdateMaxZoomLevel()
	SetCVar("cameraDistanceMaxZoomFactor", C.db["Misc"]["MaxZoom"])
end

-- Autoequip in Spec-changing
function M:AutoEquipBySpec()
	local changeSpells = {
		[63644] = true, -- second spec
		[63645] = true, -- main spec
	}
	local function setupMisc(event, unit, _, spellID)
		if not C.db["Misc"]["Autoequip"] then
			B:UnregisterEvent(event, setupMisc)
			return
		end
		if not UnitIsUnit(unit, "player") then return end
		if not changeSpells[spellID] then return end

		local spec = C_SpecializationInfo.GetSpecialization()
		if not spec or spec < 1 then return end
		local _, talentName = C_SpecializationInfo.GetSpecializationInfo(spec)
		local setID = C_EquipmentSet.GetEquipmentSetID(talentName)
		if setID then
			local _, _, _, hasEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
			if not hasEquipped then
				C_EquipmentSet.UseEquipmentSet(setID)
				print(format(DB.InfoColor..EQUIPMENT_SETS, talentName))
			end
		else
			for i = 0, C_EquipmentSet.GetNumEquipmentSets()-1 do
				local name, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(i)
				if isEquipped then
					print(format(DB.InfoColor..EQUIPMENT_SETS, name))
					break
				end
			end
		end
	end

	B:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", setupMisc, "player")
end

-- Achievement screenshot
function M:ScreenShotOnEvent()
	PlaySound(12891) -- achivement sound
	M.ScreenShotFrame.delay = 1
	M.ScreenShotFrame:Show()
end

function M:UpdateScreenShot()
	if not M.ScreenShotFrame then
		M.ScreenShotFrame = CreateFrame("Frame")
		M.ScreenShotFrame:Hide()
		M.ScreenShotFrame:SetScript("OnUpdate", function(self, elapsed)
			self.delay = self.delay - elapsed
			if self.delay < 0 then
				Screenshot()
				self:Hide()
			end
		end)
	end

	if C.db["Misc"]["Screenshot"] then
		B:RegisterEvent("ACHIEVEMENT_EARNED", M.ScreenShotOnEvent)
	else
		M.ScreenShotFrame:Hide()
		B:UnregisterEvent("ACHIEVEMENT_EARNED", M.ScreenShotOnEvent)
	end
end

-- Move and save blizz frames
function M:MoveBlizzFrames()
	if not C.db["Misc"]["BlizzMover"] then return end

	if not IsAddOnLoaded("RXPGuides") then
		B:BlizzFrameMover(CharacterFrame)
	end
	B:BlizzFrameMover(QuestLogFrame)
end


-- Archaeology counts
do
	local function CalculateArches(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine("|c0000FF00"..L["Arch Count"]..":")
		GameTooltip:AddLine(" ")
		local total = 0
		for i = 1, GetNumArchaeologyRaces() do
			local numArtifacts = GetNumArtifactsByRace(i)
			local count = 0
			for j = 1, numArtifacts do
				local completionCount = select(10, GetArtifactInfoByRace(i, j))
				count = count + completionCount
			end
			local name = GetArchaeologyRaceInfo(i)
			if numArtifacts > 1 then
				GameTooltip:AddDoubleLine(name..":", DB.InfoColor..count)
				total = total + count
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|c0000ff00"..TOTAL..":", "|cffff0000"..total)
		GameTooltip:Show()
	end

	local function AddCalculateIcon()
		local bu = CreateFrame("Button", nil, ArchaeologyFrameCompletedPage)
		bu:SetPoint("TOPRIGHT", -45, -45)
		bu:SetSize(35, 35)
		B.PixelIcon(bu, "Interface\\ICONS\\TRADE_ARCHAEOLOGY_HIGHBORNE_SCROLL", true)
		bu:SetScript("OnEnter", CalculateArches)
		bu:SetScript("OnLeave", B.HideTooltip)
	end

	local function setupMisc(event, addon)
		if addon == "Blizzard_ArchaeologyUI" then
			AddCalculateIcon()

			B:UnregisterEvent(event, setupMisc)
		end
	end

	B:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Drag AltPowerbar
do
--[[	local mover = CreateFrame("Frame", "NDuiAltBarMover", PlayerPowerBarAlt)
	mover:SetPoint("CENTER", UIParent, 0, -200)
	mover:SetSize(20, 20)
	B.CreateMF(PlayerPowerBarAlt, mover)

	hooksecurefunc(PlayerPowerBarAlt, "SetPoint", function(_, _, parent)
		if parent ~= mover then
			PlayerPowerBarAlt:ClearAllPoints()
			PlayerPowerBarAlt:SetPoint("CENTER", mover)
		end
	end)]]

	hooksecurefunc("UnitPowerBarAlt_SetUp", function(self)
		local statusFrame = self.statusFrame
		if statusFrame.enabled then
			statusFrame:Show()
			statusFrame.Hide = statusFrame.Show
		end
	end)

	PlayerPowerBarAlt:HookScript("OnEnter", function(self)
		if not NDuiADB["Help"]["AltPower"] then
			HelpTip:Show(self, altPowerInfo)
			B:ShowHelpTip(self, L["Drag AltBar Tip"], "RIGHT", 20, 0, nil, "AltPower")
		end
	end)
end

-- Fix errors in mop
if not QuestLogDailyQuestCount then
	QuestLogDailyQuestCount = CreateFrame("Frame")
end