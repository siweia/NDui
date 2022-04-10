local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:GetModule("Bags")

local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_LEGENDARY
local LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT = LE_ITEM_CLASS_CONSUMABLE, LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS = LE_ITEM_CLASS_WEAPON, LE_ITEM_CLASS_ARMOR, LE_ITEM_CLASS_TRADEGOODS
local AmmoEquipLoc = _G.INVTYPE_AMMO

-- Custom filter for consumable
local CustomFilterList = {
	[12450] = true,	-- Juju Flurry
	[12451] = true,	-- Juju Power
	[12455] = true,	-- Juju Ember
	[12457] = true, -- Juju Chill
	[12458] = true,	-- Juju Guile
	[12459] = true,	-- Juju Escape
	[12460] = true,	-- Juju Might
}

local function isCustomFilter(item)
	if not C.db["Bags"]["ItemFilter"] then return end
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
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterJunk"] then return end
	return (item.quality == LE_ITEM_QUALITY_POOR or NDuiADB["CustomJunkList"][item.id]) and item.hasPrice
end

local function isItemAmmo(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterAmmo"] then return end
	if DB.MyClass == "HUNTER" then
		return item.equipLoc == AmmoEquipLoc or module.BagsType[item.bagID] == -1
	elseif DB.MyClass == "WARLOCK" then
		return item.id == 6265 or module.BagsType[item.bagID] == 1
	end
end

local iLvlClassIDs = {
	[LE_ITEM_CLASS_ARMOR] = true,
	[LE_ITEM_CLASS_WEAPON] = true,
}
function module:IsItemHasLevel(item)
	return iLvlClassIDs[item.classID]
end

local function isItemEquipment(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterEquipment"] then return end
	return item.link and item.quality > LE_ITEM_QUALITY_COMMON and module:IsItemHasLevel(item)
end

local consumableIDs = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_ITEM_ENHANCEMENT] = true,
}
local function isItemConsumable(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterConsumable"] then return end
	if isCustomFilter(item) == false then return end
	return isCustomFilter(item) or consumableIDs[item.classID]
end

local function isItemLegendary(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterLegendary"] then return end
	return item.quality == LE_ITEM_QUALITY_LEGENDARY
end

local function isItemFavourite(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterFavourite"] then return end
	return item.id and C.db["Bags"]["FavouriteItems"][item.id]
end

local function isEmptySlot(item)
	if not C.db["Bags"]["GatherEmpty"] then return end
	return module.initComplete and not item.texture and module.BagsType[item.bagID] == 0
end

local function isItemKeyRing(item)
	return item.bagID == -2
end

local function isTradeGoods(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterGoods"] then return end
	return item.classID == LE_ITEM_CLASS_TRADEGOODS
end

local function isQuestItem(item)
	if not C.db["Bags"]["ItemFilter"] then return end
	if not C.db["Bags"]["FilterQuest"] then return end
	return item.isQuestItem
end

function module:GetFilters()
	local filters = {}

	filters.onlyBags = function(item) return isItemInBag(item) and not isEmptySlot(item) end
	filters.bagAmmo = function(item) return isItemInBag(item) and isItemAmmo(item) end
	filters.bagEquipment = function(item) return isItemInBag(item) and isItemEquipment(item) end
	filters.bagConsumable = function(item) return isItemInBag(item) and isItemConsumable(item) end
	filters.bagsJunk = function(item) return isItemInBag(item) and isItemJunk(item) end
	filters.onlyBank = function(item) return isItemInBank(item) and not isEmptySlot(item) end
	filters.bankAmmo = function(item) return isItemInBank(item) and isItemAmmo(item) end
	filters.bankLegendary = function(item) return isItemInBank(item) and isItemLegendary(item) end
	filters.bankEquipment = function(item) return isItemInBank(item) and isItemEquipment(item) end
	filters.bankConsumable = function(item) return isItemInBank(item) and isItemConsumable(item) end
	filters.onlyReagent = function(item) return item.bagID == -3 end
	filters.bagFavourite = function(item) return isItemInBag(item) and isItemFavourite(item) end
	filters.bankFavourite = function(item) return isItemInBank(item) and isItemFavourite(item) end
	filters.onlyKeyring = function(item) return isItemKeyRing(item) end
	filters.bagGoods = function(item) return isItemInBag(item) and isTradeGoods(item) end
	filters.bankGoods = function(item) return isItemInBank(item) and isTradeGoods(item) end
	filters.bagQuest = function(item) return isItemInBag(item) and isQuestItem(item) end
	filters.bankQuest = function(item) return isItemInBank(item) and isQuestItem(item) end

	return filters
end