local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_COMMON, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT, EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC
local LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT, LE_ITEM_MISCELLANEOUS_COMPANION_PET = LE_ITEM_CLASS_MISCELLANEOUS, LE_ITEM_MISCELLANEOUS_MOUNT, LE_ITEM_MISCELLANEOUS_COMPANION_PET
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID

-- Custom filter
local CustomFilterList = {
	[37863] = false,	-- 酒吧传送器
	[141333] = true,	-- 宁神圣典
	[141446] = true,	-- 宁神书卷
	[153646] = true,	-- 静心圣典
	[153647] = true,	-- 静心书卷
	[161053] = true,	-- 水手咸饼干
}

local function isCustomFilter(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return CustomFilterList[item.id]
end

-- Default filter
local function isItemInBag(item)
	return item.bagID >= 0 and item.bagID <= 4
end

local function isItemInBank(item)
	return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11
end

local function isItemJunk(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0
end

local function isAzeriteArmor(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if not item.link then return end
	return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) and not (NDuiDB["Bags"]["ItemSetFilter"] and item.isInSet)
end

local function isItemEquipment(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if NDuiDB["Bags"]["ItemSetFilter"] then
		return item.isInSet
	else
		return item.level and item.rarity > LE_ITEM_QUALITY_COMMON and (item.subType == EJ_LOOT_SLOT_FILTER_ARTIFACT_RELIC or item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR)
	end
end

local function isItemConsumble(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	if isCustomFilter(item) == false then return end
	return isCustomFilter(item) or (item.classID and (item.classID == LE_ITEM_CLASS_CONSUMABLE or item.classID == LE_ITEM_CLASS_ITEM_ENHANCEMENT))
end

local function isItemLegendary(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.rarity == LE_ITEM_QUALITY_LEGENDARY
end

local function isMountAndPet(item)
	if not NDuiDB["Bags"]["ItemFilter"] then return end
	return item.classID == LE_ITEM_CLASS_MISCELLANEOUS and (item.subClassID == LE_ITEM_MISCELLANEOUS_MOUNT or item.subClassID == LE_ITEM_MISCELLANEOUS_COMPANION_PET)
end

function module:GetFilters()
	local onlyBags = function(item) return isItemInBag(item) and not isItemEquipment(item) and not isItemConsumble(item) and not isAzeriteArmor(item) and not isItemJunk(item) and not isMountAndPet(item) end
	local bagAzeriteItem = function(item) return isItemInBag(item) and isAzeriteArmor(item) end
	local bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	local bagConsumble = function(item) return isItemInBag(item) and isItemConsumble(item) end
	local bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	local onlyBank = function(item) return isItemInBank(item) and not isItemEquipment(item) and not isItemConsumble(item) and not isAzeriteArmor(item) and not isMountAndPet(item) end
	local bankAzeriteItem = function(item) return isItemInBank(item) and isAzeriteArmor(item) end
	local bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	local bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	local bankConsumble = function(item) return isItemInBank(item) and isItemConsumble(item) end
	local onlyReagent = function(item) return item.bagID == -3 end
	local bagMountPet = function(item) return isItemInBag(item) and isMountAndPet(item) end
	local bankMountPet = function(item) return isItemInBank(item) and isMountAndPet(item) end

	return onlyBags, bagAzeriteItem, bagEquipment, bagConsumble, bagsJunk, onlyBank, bankAzeriteItem, bankLegendary, bankEquipment, bankConsumble, onlyReagent, bagMountPet, bankMountPet
end