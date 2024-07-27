local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local gsub, unpack, select = gsub, unpack, select
local C_MountJournal_GetMountInfoByID = C_MountJournal.GetMountInfoByID
local newString = "0:0:64:64:5:59:5:59"

function TT:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	local titleText = title and title:GetText()
	if titleText and not strfind(titleText, ":20:20:") then
		title:SetFormattedText("|T%s:20:20:"..newString..":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and text ~= " " then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:"..newString.."|t")
			if count > 0 then line:SetText(newText) end
		end
	end
end

function TT:HookTooltipCleared()
	self.tipModified = false
end

function TT:HookTooltipMethod()
	self:HookScript("OnTooltipCleared", TT.HookTooltipCleared)
end

function TT:ReskinRewardIcon()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))
	self.bg = B.CreateBDFrame(self.Icon, 0)
	B.ReskinIconBorder(self.IconBorder)
end

local GetTooltipTextureByType = {
	[Enum.TooltipDataType.Item] = function(id)
		return C_Item.GetItemIconByID(id)
	end,
	[Enum.TooltipDataType.Toy] = function(id)
		return C_Item.GetItemIconByID(id)
	end,
	[Enum.TooltipDataType.Spell] = function(id)
		return C_Spell.GetSpellTexture(id)
	end,
	[Enum.TooltipDataType.Mount] = function(id)
		return select(3, C_MountJournal_GetMountInfoByID(id))
	end,
}

function TT:ReskinTooltipIcons()
	-- Add Icons
	TT.HookTooltipMethod(GameTooltip)
	TT.HookTooltipMethod(ItemRefTooltip)

	for tooltipType, getTex in next, GetTooltipTextureByType do
		TooltipDataProcessor.AddTooltipPostCall(tooltipType, function(self)
			if self == GameTooltip or self == ItemRefTooltip then
				local data = self:GetTooltipData()
				local id = data and data.id
				if id then
					TT.SetupTooltipIcon(self, getTex(id))
				end
			end
		end)
	end

	-- Cut Icons
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		TT.SetupTooltipIcon(self)
	end)

	hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self)
		TT.SetupTooltipIcon(self)
	end)
	hooksecurefunc(GameTooltip, "SetAzeriteEssenceSlot", function(self)
		TT.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	TT.ReskinRewardIcon(GameTooltip.ItemTooltip)
	TT.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end