local _, ns = ...
local B, C, L, DB = unpack(ns)

-- /run UIParent_OnEvent({}, "WEEKLY_REWARDS_SHOW")
local function ReskinActivityFrame(frame, isObject)
	if frame.Border then
		if isObject then
			frame.Border:SetAlpha(0)
		else
			frame.Border:SetTexCoord(.926, 1, 0, 1)
			frame.Border:SetSize(25, 137)
			frame.Border:SetPoint("LEFT", frame, "RIGHT", 3, 0)
		end
	end

	if frame.Background then
		B.CreateBDFrame(frame.Background, 1)
	end
end

C.themes["Blizzard_WeeklyRewards"] = function()
	local WeeklyRewardsFrame = WeeklyRewardsFrame

	B.StripTextures(WeeklyRewardsFrame)
	B.SetBD(WeeklyRewardsFrame)
	B.ReskinClose(WeeklyRewardsFrame.CloseButton)

	local headerFrame = WeeklyRewardsFrame.HeaderFrame
	B.StripTextures(headerFrame)
	B.CreateBDFrame(headerFrame, .25)
	headerFrame:SetPoint("TOP", 1, -42)

	ReskinActivityFrame(WeeklyRewardsFrame.RaidFrame)
	ReskinActivityFrame(WeeklyRewardsFrame.MythicFrame)
	ReskinActivityFrame(WeeklyRewardsFrame.PVPFrame)

	for _, frame in pairs(WeeklyRewardsFrame.Activities) do
		ReskinActivityFrame(frame, true)
	end
end