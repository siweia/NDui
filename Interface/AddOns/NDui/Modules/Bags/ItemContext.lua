local _, ns = ...
local B = unpack(ns)
local module = B:GetModule("Bags")
local MatchResult = ItemButtonUtil.ItemContextMatchResult
local InteractionType = Enum.PlayerInteractionType

local contexts = {
	[InteractionType.Auctioneer] = false,
	[InteractionType.MailInfo] = false,
	[InteractionType.Merchant] = false,
	[InteractionType.GuildBanker] = false,
}

local function GetItemContextMatchResult(button)
	local bagID, slotID = button.bagId, button.slotId
	-- 只筛选随身背包；空格、尚未初始化的按钮和银行取出操作不受影响。
	if not bagID or not slotID or bagID < 0 or bagID > NUM_TOTAL_EQUIPPED_BAG_SLOTS then
		return MatchResult.DoesNotApply
	end

	local info = C_Container.GetContainerItemInfo(bagID, slotID)
	if not info then return MatchResult.DoesNotApply end

	local location = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
	local result = ItemButtonUtil.GetItemContextMatchResultForItem(location)
	if result == MatchResult.Mismatch then return result end

	local matches
	if contexts[InteractionType.Auctioneer] then
		matches = C_AuctionHouse.IsSellItemValid(location, false)
	elseif contexts[InteractionType.MailInfo] and SendMailFrame and SendMailFrame:IsShown() then
		-- 账号绑定物品仍可寄给自己的角色，不能只按灵魂绑定标记判断。
		matches = not info.isBound or C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, location)
	elseif contexts[InteractionType.Merchant] then
		matches = not info.hasNoValue or C_Item.CanBeRefunded(location)
	elseif contexts[InteractionType.GuildBanker] then
		matches = not info.isBound and not C_Item.IsBoundToAccountUntilEquip(location)
	elseif module.Bags:AtBank() then
		local bankType = BankFrame.BankPanel.bankType
		-- 首次打开银行时，背包可能先刷新；等 SetBankType 回调再检查存入资格。
		if bankType == nil then return result end
		matches = C_Bank.IsItemAllowedInBankType(bankType, location)
	else
		return result
	end

	return matches and MatchResult.Match or MatchResult.Mismatch
end

local function UpdateItemContextAppearance(button)
	if not button.bagId or not button.slotId then return end
	local info = C_Container.GetContainerItemInfo(button.bagId, button.slotId)
	-- 场景结束时仍保留物品锁定的灰色，搜索遮罩由原有搜索逻辑管理。
	button.Icon:SetDesaturated(button.itemContextMatchResult == MatchResult.Mismatch or (info and info.isLocked) or false)
end

local function UpdateItemContext(button)
	button:UpdateItemContextMatching()
end

local function UpdateAllItemContexts()
	local bags = module.Bags
	if not bags or not bags:IsShown() then return end
	for _, button in pairs(bags.buttons) do
		UpdateItemContext(button)
	end
end

local function OnInteractionChanged(event, interactionType)
	if contexts[interactionType] == nil then return end
	contexts[interactionType] = event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW"
	UpdateAllItemContexts()
end

function module:SetupItemContextButton(button)
	-- 模板方法在按钮本身，需在此替换，不能只定义在 cargBags 的类上。
	button.GetItemContextMatchResult = GetItemContextMatchResult
	hooksecurefunc(button, "UpdateItemContextOverlay", UpdateItemContextAppearance)
end

function module:SetupItemContext(buttonClass)
	-- 背包内容变化和 ITEM_LOCK_CHANGED 都经过这个回调。
	buttonClass.OnUpdateLock = UpdateItemContext
	B:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", OnInteractionChanged)
	B:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", OnInteractionChanged)
	hooksecurefunc("SetSendMailShowing", UpdateAllItemContexts)
end
