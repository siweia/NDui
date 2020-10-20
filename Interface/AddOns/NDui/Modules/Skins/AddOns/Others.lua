local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

-- WarPlan
function S:ReskinWarPlan()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end
	if not NDuiDB["Skins"]["FontOutline"] then return end
	if not IsAddOnLoaded("WarPlan") then return end

	C_Timer.After(.1, function()
		local WarPlanFrame = _G.WarPlanFrame
		if not WarPlanFrame then return end

		B.StripTextures(WarPlanFrame)
		B.SetBD(WarPlanFrame)
		B.StripTextures(WarPlanFrame.ArtFrame)
		B.ReskinClose(WarPlanFrame.ArtFrame.CloseButton)
		WarPlanFrame.ArtFrame.TitleText:SetTextColor(1, .8, 0)

		local missions = WarPlanFrame.TaskBoard.Missions
		for i = 1, #missions do
			local button = missions[i]
			if button.XPReward then
				button.XPReward:SetTextColor(1, 1, 1)
			end
			if button.Description then
				button.Description:SetTextColor(.8, .8, .8)
			end
			if button.CDTDisplay then
				button.CDTDisplay:SetTextColor(1, 1, 1)
			end

			local groups = button.Groups
			if groups then
				for j = 1, #groups do
					local group = groups[j]
					B.Reskin(group)
					if group.Features then
						group.Features:SetTextColor(1, .8, 0)
					end
				end
			end
		end

		B.Reskin(WarPlanFrame.TaskBoard.AllPurposeButton)
	end)
end

S:LoadWithAddOn("Blizzard_GarrisonUI", nil, S.ReskinWarPlan)