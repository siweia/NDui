local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_ChallengesUI"] = function()
	ChallengesFrameInset:Hide()
	local r9, r10 = select(9, ChallengesFrameDetails:GetRegions())
	r9:Hide()
	r10:Hide()

	for i = 1, 3 do
		local rewardsRow = ChallengesFrame["RewardRow"..i]
		for j = 1, 2 do
			local bu = rewardsRow["Reward"..j]
			if bu then
				B.ReskinIcon(bu.Icon)
			end
		end
	end
end