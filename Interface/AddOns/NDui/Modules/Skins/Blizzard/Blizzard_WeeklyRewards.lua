local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

-- /run UIParent_OnEvent({}, "WEEKLY_REWARDS_SHOW")

local function updateSelection(frame)
	if not frame.bg then return end

	if frame.SelectedTexture:IsShown() then
		frame.bg:SetBackdropBorderColor(1, .8, 0)
	else
		frame.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local iconColor = DB.QualityColors[Enum.ItemQuality.Epic or 4] -- epic color only
local function reskinRewardIcon(itemFrame)
	if not itemFrame.bg then
		itemFrame:DisableDrawLayer("BORDER")
		itemFrame.Icon:SetPoint("LEFT", 6, 0)
		itemFrame.bg = B.ReskinIcon(itemFrame.Icon)
		itemFrame.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
	end
end

local function fixBg(anim) -- color reset for the first time game launched
	if anim.bg then
		anim.bg:SetBackdropColor(0, 0, 0, .25)
	end
end

local function ReskinActivityFrame(frame, isObject)
	if frame.Border then
		if isObject then
			frame.Border:SetAlpha(0)
			frame.SelectedTexture:SetAlpha(0)
			frame.LockIcon:SetVertexColor(r, g, b)
			hooksecurefunc(frame, "SetSelectionState", updateSelection)
			hooksecurefunc(frame.ItemFrame, "SetDisplayedItem", reskinRewardIcon)

			if frame.SheenAnim then
				frame.SheenAnim.bg = B.CreateBDFrame(frame.ItemFrame, .25)
				frame.SheenAnim:HookScript("OnFinished", fixBg)
			end
		else
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:SetSize(25, 137)
			frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
		end
	end

	if frame.Background then
		frame.bg = B.CreateBDFrame(frame.Background, 1)
	end
end

local function replaceIconString(self, text)
	if not text then text = self:GetText() end
	if not text or text == "" then return end

	local newText, count = gsub(text, "24:24:0:%-2", "14:14:0:0:64:64:5:59:5:59")
	if count > 0 then self:SetFormattedText("%s", newText) end
end

local function reskinConfirmIcon(frame)
	if frame.bg then return end
	frame.bg = B.ReskinIcon(frame.Icon)
	B.ReskinIconBorder(frame.IconBorder, true)
end

C.themes["Blizzard_WeeklyRewards"] = function()
	local WeeklyRewardsFrame = WeeklyRewardsFrame

	B.StripTextures(WeeklyRewardsFrame)
	B.SetBD(WeeklyRewardsFrame)
	B.ReskinClose(WeeklyRewardsFrame.CloseButton)
	B.StripTextures(WeeklyRewardsFrame.SelectRewardButton)
	B.Reskin(WeeklyRewardsFrame.SelectRewardButton)
	WeeklyRewardsFrame.NineSlice:SetAlpha(0)
	WeeklyRewardsFrame.BackgroundTile:SetAlpha(0)

	local headerFrame = WeeklyRewardsFrame.HeaderFrame
	B.StripTextures(headerFrame)
	--B.CreateBDFrame(headerFrame, .25)
	headerFrame:SetPoint("TOP", 1, -42)
	headerFrame.Text:SetFontObject(SystemFont_Huge1)

	ReskinActivityFrame(WeeklyRewardsFrame.RaidFrame)
	ReskinActivityFrame(WeeklyRewardsFrame.MythicFrame)
	ReskinActivityFrame(WeeklyRewardsFrame.PVPFrame)
	if DB.isWW then
		ReskinActivityFrame(WeeklyRewardsFrame.WorldFrame)
	end

	for _, frame in pairs(WeeklyRewardsFrame.Activities) do
		ReskinActivityFrame(frame, true)
	end

	hooksecurefunc(WeeklyRewardsFrame, "SelectReward", function(self)
		local confirmFrame = self.confirmSelectionFrame
		if confirmFrame then
			if not confirmFrame.styled then
				reskinConfirmIcon(confirmFrame.ItemFrame)
				WeeklyRewardsFrameNameFrame:Hide()
				confirmFrame.styled = true
			end

			local alsoItemsFrame = confirmFrame.AlsoItemsFrame
			if alsoItemsFrame.pool then
				for frame in alsoItemsFrame.pool:EnumerateActive() do
					reskinConfirmIcon(frame)
				end
			end
		end
	end)

	local rewardText = WeeklyRewardsFrame.ConcessionFrame.RewardsFrame.Text
	replaceIconString(rewardText)
	hooksecurefunc(rewardText, "SetText", replaceIconString)
end