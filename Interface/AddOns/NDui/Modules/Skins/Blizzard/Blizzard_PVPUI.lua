local _, ns = ...
local B, C, L, DB = unpack(ns)

C.themes["Blizzard_PVPUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	local PVPQueueFrame = PVPQueueFrame
	local HonorFrame = HonorFrame
	local ConquestFrame = ConquestFrame

	-- Category buttons

	local iconSize = 60-2*C.mult
	for i = 1, 4 do
		local bu = PVPQueueFrame["CategoryButton"..i]
		if bu then
			local icon = bu.Icon
			local cu = bu.CurrencyDisplay
	
			bu.Ring:Hide()
			B.Reskin(bu, true)
			bu.Background:SetInside(bu.__bg)
			bu.Background:SetColorTexture(r, g, b, .25)
			bu.Background:SetAlpha(1)
	
			icon:SetPoint("LEFT", bu, "LEFT")
			icon:SetSize(iconSize, iconSize)
			B.ReskinIcon(icon)
	
			if cu then
				local ic = cu.Icon
	
				ic:SetSize(16, 16)
				ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
				cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)
				B.ReskinIcon(ic)
			end
		end
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
	PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\ability_warrior_offensivestance")

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		for i = 1, 3 do
			local bu = PVPQueueFrame["CategoryButton"..i]
			if i == index then
				bu.Background:Show()
			else
				bu.Background:Hide()
			end
		end
	end)

	PVPQueueFrame.CategoryButton1.Background:SetAlpha(1)

	-- Honor frame

	B.StripTextures(HonorQueueFrame.RoleInset)
	B.ReskinRole(HonorQueueFrame.RoleInset.TankIcon)
	B.ReskinRole(HonorQueueFrame.RoleInset.HealerIcon)
	B.ReskinRole(HonorQueueFrame.RoleInset.DPSIcon)
	B.Reskin(HonorQueueFrameSoloQueueButton)
	B.Reskin(HonorQueueFrameGroupQueueButton)
	if HonorQueueFrameTypeDropdown then
		B.ReskinDropDown(HonorQueueFrameTypeDropdown)
	end
	if HonorQueueFrameTypeDropDown then
		B.StripTextures(HonorQueueFrameTypeDropDown)
		local button = HonorQueueFrameTypeDropDownButton
		if button then
			B.Reskin(button, true)
			local tex = button:CreateTexture(nil, "ARTWORK")
			tex:SetAllPoints(button)
			B.SetupArrow(tex, "down")
			button.__texture = tex
			button:HookScript("OnEnter", B.Texture_OnEnter)
			button:HookScript("OnLeave", B.Texture_OnLeave)
		end
	end

	B.StripTextures(HonorQueueFrame.Inset)

	local bonusFrame = HonorQueueFrame.BonusFrame
	B.StripTextures(bonusFrame)
	bonusFrame.WorldBattlesTexture:Hide()
	bonusFrame.ShadowOverlay:Hide()
	B.Reskin(bonusFrame.DiceButton)

	for _, bonusButton in pairs({"RandomBGButton", "CallToArmsButton", "WorldPVP1Button", "WorldPVP2Button"}) do
		local bu = bonusFrame[bonusButton]
		if bu then
			B.Reskin(bu, true)
			bu.SelectedTexture:SetDrawLayer("BACKGROUND")
			bu.SelectedTexture:SetColorTexture(r, g, b, .25)
			bu.SelectedTexture:SetInside(bu.__bg)

			local reward = bu.Reward
			if reward then
				reward.Border:Hide()
				reward.CircleMask:Hide()
				reward.Icon.bg = B.ReskinIcon(reward.Icon)
			end
		end
	end

	-- Conquest frame

	B.StripTextures(ConquestQueueFrame)
	ConquestQueueFrame.ShadowOverlay:Hide()
	B.StripTextures(ConquestQueueFrame.Inset)
	B.Reskin(ConquestJoinButton)

	local names = {"Arena2v2", "Arena3v3", "Arena5v5", "RatedBG"}
	for _, name in pairs(names) do
		local bu = ConquestQueueFrame[name]
		if bu then
			B.Reskin(bu, true)
			local reward = bu.Reward
			if reward then
				reward.Border:Hide()
				reward.CircleMask:Hide()
				reward.Icon.bg = B.ReskinIcon(reward.Icon)
			end

			bu.SelectedTexture:SetDrawLayer("BACKGROUND")
			bu.SelectedTexture:SetColorTexture(r, g, b, .25)
			bu.SelectedTexture:SetInside(bu.__bg)
		end
	end

	local bar = ConquestQueueFrameConquestBar
	if bar then
		B.StripTextures(bar)
		B.CreateBDFrame(bar, .25)
	end

	-- WarGames frame, blizzard is now WIP
	B.StripTextures(WarGamesQueueFrame)
	B.CreateBDFrame(WarGamesQueueFrameScrollFrameScrollBar, .25)
	B.Reskin(WarGameStartButton)
	B.ReskinScroll(WarGamesQueueFrameScrollFrameScrollBar)
	B.ReskinTrimScroll(WarGamesQueueFrameInfoScrollFrame.ScrollBar)
end