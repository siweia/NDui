local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local strfind, gsub, unpack = string.find, gsub, unpack
local GetItemIcon, GetSpellTexture = GetItemIcon, GetSpellTexture
local newString = "0:0:64:64:5:59:5:59"

function TT:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName().."TextLeft1"]
	if title then
		title:SetFormattedText("|T%s:20:20:"..newString..":%d|t %s", icon, 20, title:GetText())
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		if not line then break end
		local text = line:GetText() or ""
		if strmatch(text, "|T.-:[%d+:]+|t") then
			line:SetText(gsub(text, "|T(.-):[%d+:]+|t", "|T%1:20:20:"..newString.."|t"))
		end
	end
end

function TT:HookTooltipCleared()
	self.tipModified = false
end

function TT:HookTooltipSetItem()
	if not self.tipModified then
		local _, link = self:GetItem()
		if link then
			TT.SetupTooltipIcon(self, GetItemIcon(link))
		end

		self.tipModified = true
	end
end

function TT:HookTooltipSetSpell()
	if not self.tipModified then
		local _, id = self:GetSpell()
		if id then
			TT.SetupTooltipIcon(self, GetSpellTexture(id))
		end

		self.tipModified = true
	end
end

function TT:HookTooltipMethod()
	self:HookScript("OnTooltipSetItem", TT.HookTooltipSetItem)
	self:HookScript("OnTooltipSetSpell", TT.HookTooltipSetSpell)
	self:HookScript("OnTooltipCleared", TT.HookTooltipCleared)
end

function TT:ReskinRewardIcon()
	if self and self.Icon then
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.IconBorder:SetAlpha(0)
	end
end

local function reskinQuestCurrencyRewardIcon(_, _, self)
	TT.ReskinRewardIcon(self)
end

function TT:ReskinTooltipIcons()
	TT.HookTooltipMethod(GameTooltip)
	TT.HookTooltipMethod(ItemRefTooltip)

	-- Tooltip rewards icon
	_G.BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT = "|T%1$s:16:16:"..newString.."|t |cffffffff%2$s|r %3$s"
	_G.BONUS_OBJECTIVE_REWARD_FORMAT = "|T%1$s:16:16:"..newString.."|t %2$s"

	hooksecurefunc("EmbeddedItemTooltip_SetItemByQuestReward", TT.ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetItemByID", TT.ReskinRewardIcon)
	hooksecurefunc("EmbeddedItemTooltip_SetCurrencyByID", TT.ReskinRewardIcon)
	hooksecurefunc("QuestUtils_AddQuestCurrencyRewardsToTooltip", reskinQuestCurrencyRewardIcon)
end