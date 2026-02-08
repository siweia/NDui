local _, ns = ...
local B, C, L, DB = unpack(ns)
local TT = B:GetModule("Tooltip")

local gsub, unpack, strfind = gsub, unpack, strfind
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
		if text and text ~= " " and not strfind(text, "UI%-CharacterCreate%-Classes") then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:"..newString.."|t")
			if count > 0 then line:SetText(newText) end
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

local function updateBackdropColor(self, r, g, b)
	self:GetParent().bg:SetBackdropBorderColor(r, g, b)
end

local function resetBackdropColor(self)
	self:GetParent().bg:SetBackdropBorderColor(0, 0, 0)
end

function TT:ReskinRewardIcon()
	self.Icon:SetTexCoord(unpack(DB.TexCoord))
	self.bg = B.CreateBDFrame(self, 0)
	self.bg:SetOutside(self.Icon)

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)
	hooksecurefunc(iconBorder, "SetVertexColor", updateBackdropColor)
	hooksecurefunc(iconBorder, "Hide", resetBackdropColor)
end

function TT:ReskinTooltipIcons()
	TT.HookTooltipMethod(GameTooltip)
	TT.HookTooltipMethod(ItemRefTooltip)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		TT.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	TT.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end