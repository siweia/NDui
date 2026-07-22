-----------------------------------------
-- SortBags, shirsig
-- https://github.com/shirsig/SortBags
-----------------------------------------
local _, ns = ...
local B, C, L, DB = unpack(ns)

local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

local PickupContainerItem = C_Container and C_Container.PickupContainerItem or PickupContainerItem
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetContainerNumFreeSlots = C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo or GetContainerItemInfo
local GetContainerItemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
local GetItemFamily = C_Item and C_Item.GetItemFamily or GetItemFamily
local bit_band = bit.band

CreateFrame('GameTooltip', 'SortBagsTooltip', nil, 'GameTooltipTemplate')

BAG_CONTAINERS = {0, 1, 2, 3, 4}
BANK_BAG_CONTAINERS = {-1, 5, 6, 7, 8, 9, 10, 11}

function _G.SortBags()
	CONTAINERS = {unpack(BAG_CONTAINERS)}
	Start()
end

function _G.SortBankBags()
	CONTAINERS = {unpack(BANK_BAG_CONTAINERS)}
	Start()
end

function _G.GetSortBagsRightToLeft(enabled)
	return SortBagsRightToLeft
end

function _G.SetSortBagsRightToLeft(enabled)
	_G.SortBagsRightToLeft = enabled and 1 or nil
end

local function set(...)
	local t = {}
	local n = select('#', ...)
	for i = 1, n do
		t[select(i, ...)] = true
	end
	return t
end

local SPECIAL = set(5462, 9173, 11511, 13347, 32542, 33219, 38233, 40110, 43499, 43824, 198647)

local KEYS = set(9240, 11511, 12324, 12384, 13544, 16309, 17191, 20402)

local TOOLS = set(6218, 6339, 11130, 11145, 16207, 22461, 22462, 22463, 5060, 7005, 12709, 19727, 5956, 2901, 6219, 10498, 9149, 15846, 6256, 6365, 6366, 6367, 12225, 19022, 25978, 19970, 20815, 20824, 25978, 44452, 36898, 44451, 45991, 45992, 44050, 39505)

do
	local f = CreateFrame'Frame'
	local lastUpdate = 0
	local function updateHandler()
		if GetTime() - lastUpdate > 1 then
			for _, container in pairs(BAG_CONTAINERS) do
				for position = 1, GetContainerNumSlots(container) do
					SetScanTooltip(container, position)
				end
			end
			for _, container in pairs(BANK_BAG_CONTAINERS) do
				for position = 1, GetContainerNumSlots(container) do
					SetScanTooltip(container, position)
				end
			end
			f:SetScript('OnUpdate', nil)
		end
	end
	f:SetScript('OnEvent', function()
		lastUpdate = GetTime()
		f:SetScript('OnUpdate', updateHandler)
	end)
	f:RegisterEvent'BAG_UPDATE'
	f:RegisterEvent'BANKFRAME_OPENED'
end

local model, itemStacks, itemFamilies, itemSortKeys

local function IsFamilyCompatible(containerFamily, itemFamily)
	return containerFamily and itemFamily and bit_band(containerFamily, itemFamily) ~= 0
end

do
	local f = CreateFrame'Frame'

	local process = coroutine.create(function() end);

	local suspended

	function Start()
		process = coroutine.create(function()
			while not Initialize() do
				coroutine.yield()
			end
			while true do
				suspended = false
				if InCombatLockdown() then
					return
				end
				local complete = Sort()
				if complete then
					return
				end
				Stack()
				if not suspended then
					coroutine.yield()
				end
			end
		end)
		f:Show()
	end

	f:SetScript('OnUpdate', function(_, arg1)
		if coroutine.status(process) == 'suspended' then
			suspended = true
			coroutine.resume(process)
		end
		if coroutine.status(process) == 'dead' then
			f:Hide()
		end
	end)
end

function LT(a, b)
	local i = 1
	while true do
		if a[i] and b[i] and a[i] ~= b[i] then
			return a[i] < b[i]
		elseif not a[i] and b[i] then
			return true
		elseif not b[i] then
			return false
		end
		i = i + 1
	end
end

function Move(src, dst)
	if InCombatLockdown() then return end -- might block in combat, needs review

	local srcInfo = GetContainerItemInfo(src.container, src.position)
	local texture = srcInfo and srcInfo.iconFileID
	local srcLocked = srcInfo and srcInfo.isLocked
	local dstInfo = GetContainerItemInfo(dst.container, dst.position)
	local dstLocked = dstInfo and dstInfo.isLocked

	if texture and not srcLocked and not dstLocked then
		ClearCursor()
		PickupContainerItem(src.container, src.position)
		PickupContainerItem(dst.container, dst.position)

		if src.item == dst.item then
			local count = min(src.count, itemStacks[dst.item] - dst.count)
			src.count = src.count - count
			dst.count = dst.count + count
			if src.count == 0 then
				src.item = nil
			end
		else
			src.item, dst.item = dst.item, src.item
			src.count, dst.count = dst.count, src.count
		end

		coroutine.yield()
		return true
	end
end

do
	local patterns = {}
	for i = 1, 10 do
		local text = gsub(format(ITEM_SPELL_CHARGES, i), '(-?%d+)(.-)|4([^;]-);', function(numberString, gap, numberForms)
			local singular, dual, plural
			_, _, singular, dual, plural = strfind(numberForms, '(.+):(.+):(.+)');
			if not singular then
				_, _, singular, plural = strfind(numberForms, '(.+):(.+)')
			end
			local i = abs(tonumber(numberString))
			local numberForm
			if i == 1 then
				numberForm = singular
			elseif i == 2 then
				numberForm = dual or plural
			else
				numberForm = plural
			end
			return numberString .. gap .. numberForm
		end)
		patterns[text] = i
	end

	function itemCharges(text)
		return patterns[text]
	end
end

function TooltipInfo(container, position)
	SetScanTooltip(container, position)

	local charges, usable, soulbound, conjured
	for i = 1, SortBagsTooltip:NumLines() do
		local text = getglobal('SortBagsTooltipTextLeft' .. i):GetText()

		local extractedCharges = itemCharges(text)
		if extractedCharges then
			charges = extractedCharges
		elseif strfind(text, '^' .. ITEM_SPELL_TRIGGER_ONUSE) then
			usable = true
		elseif text == ITEM_SOULBOUND then
			soulbound = true
		elseif text == ITEM_CONJURED then
			conjured = true
		end
	end

	return charges or 1, usable, soulbound, conjured
end

function SetScanTooltip(container, position)
	SortBagsTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
	SortBagsTooltip:ClearLines()

	if container == BANK_CONTAINER then
		SortBagsTooltip:SetInventoryItem('player', BankButtonIDToInvSlotID(position))
	else
		SortBagsTooltip:SetBagItem(container, position)
	end
end

function Sort()
	local complete, moved
	repeat
		complete, moved = true, false
		for _, dst in ipairs(model) do
			if dst.targetItem and (dst.item ~= dst.targetItem or dst.count < dst.targetCount) then
				complete = false

				local sources, rank = {}, {}

				for _, src in ipairs(model) do
					if src.item == dst.targetItem
						and src ~= dst
						and not (dst.item and src.family and not IsFamilyCompatible(src.family, itemFamilies[dst.item]))
						and not (src.targetItem and src.item == src.targetItem and src.count <= src.targetCount)
					then
						rank[src] = abs(src.count - dst.targetCount + (dst.item == dst.targetItem and dst.count or 0))
						tinsert(sources, src)
					end
				end

				sort(sources, function(a, b) return rank[a] < rank[b] end)

				for _, src in ipairs(sources) do
					if Move(src, dst) then
						moved = true
						break
					end
				end
			end
		end
	until complete or not moved
	return complete
end

function Stack()
	for _, src in ipairs(model) do
		if src.item and src.count < itemStacks[src.item] and src.item ~= src.targetItem then
			for _, dst in ipairs(model) do
				if dst ~= src and dst.item and dst.item == src.item and dst.count < itemStacks[dst.item] and dst.item ~= dst.targetItem then
					if Move(src, dst) then
						return
					end
				end
			end
		end
	end
end

do
	local counts

	local function insert(t, v)
		if SortBagsRightToLeft then
			tinsert(t, v)
		else
			tinsert(t, 1, v)
		end
	end

	local function assign(slot, item)
		if counts[item] > 0 then
			local count
			if SortBagsRightToLeft and mod(counts[item], itemStacks[item]) ~= 0 then
				count = mod(counts[item], itemStacks[item])
			else
				count = min(counts[item], itemStacks[item])
			end
			slot.targetItem = item
			slot.targetCount = count
			counts[item] = counts[item] - count
			return true
		end
	end

	function Initialize()
		model, counts, itemStacks, itemFamilies, itemSortKeys = {}, {}, {}, {}, {}

		for _, container in ipairs(CONTAINERS) do
			local family = ContainerFamily(container)
			for position = 1, GetContainerNumSlots(container) do
				local slot = {container=container, position=position, family=family}
				local item = Item(container, position)
				if item then
					local info = GetContainerItemInfo(container, position)
					local count = info and info.stackCount
					local locked = info and info.isLocked

					if locked then
						return false
					end
					slot.item = item
					slot.count = count
					counts[item] = (counts[item] or 0) + count
				end
				insert(model, slot)
			end
		end

		local items = {}
		for item in pairs(counts) do
			tinsert(items, item)
		end
		sort(items, function(a, b) return LT(itemSortKeys[a], itemSortKeys[b]) end)

		local specialStacks = {}
		for _, item in ipairs(items) do
			if itemFamilies[item] then
				local stacks = ceil(counts[item] / itemStacks[item])
				for _ = 1, stacks do
					tinsert(specialStacks, {item=item, family=itemFamilies[item]})
				end
			end
		end

		-- Reassign flexible items as needed so narrow bag families keep a compatible stack.
		local stackSlots, slotStacks = {}, {}
		local function matchSpecialSlot(slot, visited)
			for _, stack in ipairs(specialStacks) do
				if not visited[stack] and IsFamilyCompatible(slot.family, stack.family) then
					visited[stack] = true
					local occupiedSlot = stackSlots[stack]
					if not occupiedSlot or matchSpecialSlot(occupiedSlot, visited) then
						stackSlots[stack] = slot
						slotStacks[slot] = stack
						return true
					end
				end
			end
		end

		for _, slot in ipairs(model) do
			if slot.family then
				matchSpecialSlot(slot, {})
			end
		end

		for _, slot in ipairs(model) do
			local stack = slotStacks[slot]
			if stack then
				assign(slot, stack.item)
			end
		end

		for _, slot in ipairs(model) do
			if not slot.family then
				for _, item in ipairs(items) do
					if assign(slot, item) then
						break
					end
				end
			end
		end
		return true
	end
end

function ContainerFamily(container)
	if container ~= 0 and container ~= BANK_CONTAINER then
		local _, family = GetContainerNumFreeSlots(container)
		if family and family ~= 0 then
			return family
		end
	end
end

function Item(container, position)
	local link = GetContainerItemLink(container, position)
	if link then
		local _, _, itemID, enchantID, suffixID, uniqueID = strfind(link, 'item:(%d+):(%d*):%d*:%d*:%d*:%d*:(%-?%d*):(%-?%d*)')
		itemID = tonumber(itemID)
		local itemName, _, quality, _, _, _, _, stack, slot, _, sellPrice, classId, subClassId, bindType = GetItemInfo('item:' .. itemID)
		local charges, usable, soulbound, conjured = TooltipInfo(container, position)
		local sortKey = {}

		-- hearthstone
		if itemID == 6948 or itemID == 184871 then
			tinsert(sortKey, 1)

		-- special items
		elseif SPECIAL[itemID] then
			tinsert(sortKey, 2)

		-- key items
		elseif KEYS[itemID] then
			tinsert(sortKey, 3)

		-- tools
		elseif TOOLS[itemID] then
			tinsert(sortKey, 4)

		-- soul shards
		elseif itemID == 6265 then
			tinsert(sortKey, 12)

		-- conjured items
		elseif conjured then
			tinsert(sortKey, 13)

		-- soulbound items
		elseif soulbound then
			tinsert(sortKey, 5)

		-- reagents
		elseif classId == 9 then
			tinsert(sortKey, 6)

		-- quest items
		elseif bindType == 4 then
			tinsert(sortKey, 8)

		-- consumables
		elseif usable and classId ~= 1 and classId ~= 2 and classId ~= 8 or classId == 4 then
			tinsert(sortKey, 7)

		-- higher quality
		elseif quality > 1 then
			tinsert(sortKey, 9)

		-- common quality
		elseif quality == 1 then
			tinsert(sortKey, 10)
			tinsert(sortKey, -sellPrice)

		-- junk
		elseif quality == 0 then
			tinsert(sortKey, 11)
			tinsert(sortKey, sellPrice)
		end

		tinsert(sortKey, classId)
		tinsert(sortKey, slot)
		tinsert(sortKey, subClassId)
		tinsert(sortKey, -quality)
		tinsert(sortKey, itemName)
		tinsert(sortKey, itemID)
		tinsert(sortKey, (SortBagsRightToLeft and 1 or -1) * charges)
		tinsert(sortKey, suffixID)
		tinsert(sortKey, enchantID)
		tinsert(sortKey, uniqueID)

		local key = format('%s:%s:%s:%s:%s:%s', itemID, enchantID, suffixID, uniqueID, charges, (soulbound and 1 or 0))

		itemStacks[key] = stack
		itemSortKeys[key] = sortKey

		local family = GetItemFamily and GetItemFamily(itemID)
		if family and family ~= 0 then
			itemFamilies[key] = family
		end

		return key
	end
end
