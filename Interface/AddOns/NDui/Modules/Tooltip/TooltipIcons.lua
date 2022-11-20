local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local gsub, unpack = gsub, unpack
local GetItemIcon, GetSpellTexture = GetItemIcon, GetSpellTexture
local newString = "0:0:64:64:5:59:5:59"

function TT:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	local titleText = title and title:GetText()
	if titleText then
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

function TT:ReskinTooltipIcons()
	-- Add Icons
	TT.HookTooltipMethod(GameTooltip)
	TT.HookTooltipMethod(ItemRefTooltip)

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self)
		if self == GameTooltip or self == ItemRefTooltip then
			local _, link = self:GetItem()
			if link then
				TT.SetupTooltipIcon(self, GetItemIcon(link))
			end
		end
	end)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self)
		if self == GameTooltip or self == ItemRefTooltip then
			local _, id = self:GetSpell()
			if id then
				TT.SetupTooltipIcon(self, GetSpellTexture(id))
			end
		end
	end)

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