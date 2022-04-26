local _, ns = ...
local B, C, L, DB = unpack(ns)
local M = B:RegisterModule("Misc")

local _G = getfenv(0)
local tonumber, strmatch = tonumber, strmatch
local InCombatLockdown, IsModifiedClick, IsAltKeyDown = InCombatLockdown, IsModifiedClick, IsAltKeyDown
local GetNumAuctionItems, GetAuctionItemInfo = GetNumAuctionItems, GetAuctionItemInfo
local FauxScrollFrame_GetOffset, SetMoneyFrameColor = FauxScrollFrame_GetOffset, SetMoneyFrameColor
local GetItemInfo = GetItemInfo
local BuyMerchantItem = BuyMerchantItem
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetItemQualityColor = GetItemQualityColor
local GetTime, GetCVarBool, SetCVar = GetTime, GetCVarBool, SetCVar
local GetNumLootItems, LootSlot = GetNumLootItems, LootSlot
local GetInstanceInfo = GetInstanceInfo
local IsGuildMember, BNGetGameAccountInfoByGUID, C_FriendList_IsFriend = IsGuildMember, BNGetGameAccountInfoByGUID, C_FriendList.IsFriend
local UnitName, GetPetHappiness = UnitName, GetPetHappiness
local UnitIsPlayer, GuildInvite, C_FriendList_AddFriend = UnitIsPlayer, GuildInvite, C_FriendList.AddFriend
local TakeTaxiNode, IsMounted, Dismount, C_Timer_After = TakeTaxiNode, IsMounted, Dismount, C_Timer.After

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
			func()
		end
	end

	-- Init
	M:UIWidgetFrameMover()
	M:MoveDurabilityFrame()
	M:MoveTicketStatusFrame()
	M:UpdateFasterLoot()
	M:UpdateErrorBlocker()
	M:TradeTargetInfo()
	M:ToggleTaxiDismount()
	M:BidPriceHighlight()
	M:BlockStrangerInvite()
	M:TogglePetHappiness()
	M:QuickMenuButton()
	M:BaudErrorFrameHelpTip()
	M:EnhancedPicker()
	C_Timer_After(0, M.UpdateMaxZoomLevel)

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
				self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end
		end)
	end

	-- Fix blizz error
	MAIN_MENU_MICRO_ALERT_PRIORITY = MAIN_MENU_MICRO_ALERT_PRIORITY or {}

	-- Still exisits in 1.14.3.43154
	if not InspectTalentFrameSpentPoints then
		InspectTalentFrameSpentPoints = CreateFrame("Frame")
	end

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
end

-- Reanchor Vehicle
function M:VehicleSeatMover()
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
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
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

-- Temporary taint fix
do
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		InterfaceOptionsFrameOkay:Click()
	end)
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
function M:MenuButton_AddFriend()
	C_FriendList_AddFriend(M.MenuButtonName)
end

function M:MenuButton_CopyName()
	local editBox = ChatEdit_ChooseBoxForSend()
	local hasText = (editBox:GetText() ~= "")
	ChatEdit_ActivateChat(editBox)
	editBox:Insert(M.MenuButtonName)
	if not hasText then editBox:HighlightText() end
end

function M:MenuButton_GuildInvite()
	GuildInvite(M.MenuButtonName)
end

function M:QuickMenuButton()
	if not C.db["Misc"]["MenuButton"] then return end

	local menuList = {
		{text = ADD_FRIEND, func = M.MenuButton_AddFriend, color = {0, .6, 1}},
		{text = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, ""), func = M.MenuButton_GuildInvite, color = {0, .8, 0}},
		{text = COPY_NAME, func = M.MenuButton_CopyName, color = {1, 0, 0}},
	}

	local frame = CreateFrame("Frame", "NDuiMenuButtonFrame", DropDownList1)
	frame:SetSize(10, 10)
	frame:SetPoint("TOPLEFT")
	frame:Hide()
	for i = 1, 3 do
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(25, 10)
		button:SetPoint("TOPLEFT", frame, (i-1)*28 + 2, -2)
		B.PixelIcon(button, nil, true)
		button.Icon:SetColorTexture(unpack(menuList[i].color))
		button:SetScript("OnClick", menuList[i].func)
		B.AddTooltip(button, "ANCHOR_TOP", menuList[i].text)
	end

	hooksecurefunc("ToggleDropDownMenu", function(level, _, dropdownMenu)
		if level and level > 1 then return end

		local name = dropdownMenu.name
		local unit = dropdownMenu.unit
		local bnetID = dropdownMenu.bnetIDAccount
		local isPlayer = unit and UnitIsPlayer(unit)
		local isFriendMenu = dropdownMenu == FriendsDropDown -- menus on FriendsFrame
		if not name or (not isPlayer and not dropdownMenu.chatType and not isFriendMenu) then
			frame:Hide()
			return
		end

		if bnetID then
			local gameID = select(6, BNGetFriendInfoByID(bnetID))
			if gameID then
				local _, characterName, client, realmName = BNGetGameAccountInfo(gameID)
				if client == "WoW" and realmName ~= "" then
					M.MenuButtonName = characterName.."-"..realmName
					frame:Show()
				end
			end
		else
			local server = dropdownMenu.server
			if not server or server == "" then
				server = DB.MyRealm
			end
			M.MenuButtonName = name.."-"..server
			frame:Show()
		end
	end)
end

-- Auto dismount on Taxi
function M:ToggleTaxiDismount()
	local lastTaxiIndex

	local function retryTaxi()
		if InCombatLockdown() then return end
		if lastTaxiIndex then
			TakeTaxiNode(lastTaxiIndex)
			lastTaxiIndex = nil
		end
	end

	hooksecurefunc("TakeTaxiNode", function(index)
		if not C.db["Misc"]["AutoDismount"] then return end
		if not IsMounted() then return end

		Dismount()
		lastTaxiIndex = index
		C_Timer_After(.5, retryTaxi)
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

-- Hunter pet happiness
local petHappinessStr, lastHappiness = {
	[1] = L["PetUnhappy"],
	[2] = L["PetBadMood"],
	[3] = L["PetHappy"],
}

local function CheckPetHappiness(_, unit)
	if unit ~= "pet" then return end

	local happiness = GetPetHappiness()
	if not lastHappiness or lastHappiness ~= happiness then
		local str = petHappinessStr[happiness]
		if str then
			local petName = UnitName(unit)
			UIErrorsFrame:AddMessage(format(str, DB.InfoColor, petName))
			print(DB.NDuiString, format(str, DB.InfoColor, petName))
		end

		lastHappiness = happiness
	end
end

function M:TogglePetHappiness()
	if DB.MyClass ~= "HUNTER" then return end

	if C.db["Misc"]["PetHappiness"] then
		B:RegisterEvent("UNIT_HAPPINESS", CheckPetHappiness)
	else
		B:UnregisterEvent("UNIT_HAPPINESS", CheckPetHappiness)
	end
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

	local fixedShaman = {r=0, g=.44, b=.87, colorStr="ff0070DD"}
	local count = 0
	for name, class in pairs(DB.ClassList) do
		local value = class == "SHAMAN" and fixedShaman or DB.ClassColors[class]
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