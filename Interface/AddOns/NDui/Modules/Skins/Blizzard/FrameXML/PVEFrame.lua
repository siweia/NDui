local _, ns = ...
local B, C, L, DB = unpack(ns)
local r, g, b = DB.r, DB.g, DB.b

local function styleRewardButton(button)
	if not button or button.styled then return end

	local buttonName = button:GetName()
	local icon = _G[buttonName.."IconTexture"]
	local shortageBorder = _G[buttonName.."ShortageBorder"]
	local count = _G[buttonName.."Count"]
	local nameFrame = _G[buttonName.."NameFrame"]
	local border = button.IconBorder

	button.bg = B.ReskinIcon(icon)
	local bg = B.CreateBDFrame(button, .25)
	bg:SetPoint("TOPLEFT", button.bg, "TOPRIGHT", 1, 0)
	bg:SetPoint("BOTTOMRIGHT", button.bg, "BOTTOMRIGHT", 105, 0)

	if shortageBorder then shortageBorder:SetAlpha(0) end
	if count then count:SetDrawLayer("OVERLAY") end
	if nameFrame then nameFrame:SetAlpha(0) end
	if border then B.ReskinIconBorder(border) end

	button.styled = true
end

local function reskinDialogReward(button)
	if button.styled then return end

	local border = _G[button:GetName().."Border"]
	button.texture:SetTexCoord(unpack(DB.TexCoord))
	border:SetColorTexture(0, 0, 0)
	border:SetDrawLayer("BACKGROUND")
	border:SetOutside(button.texture)
	button.styled = true
end

local function updateRoleBonus(roleButton)
	if not roleButton.bg then return end
	if roleButton.shortageBorder and roleButton.shortageBorder:IsShown() then
		roleButton.bg:SetBackdropBorderColor(1, .9, .06)
	else
		roleButton.bg:SetBackdropBorderColor(0, 0, 0)
	end
end

local function styleRewardRole(roleIcon)
	if roleIcon and roleIcon:IsShown() then
		B.ReskinSmallRole(roleIcon.texture, roleIcon.role)
	end
end

tinsert(C.defaultThemes, function()
	PVEFrameLeftInset:SetAlpha(0)
	PVEFrameBlueBg:SetAlpha(0)
	PVEFrame.shadows:SetAlpha(0)

	GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
	GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT")
	GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\Icons\\inv_helmet_06")
	if DB.isMop then
		GroupFinderFrameGroupButton4.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")
	end

	local iconSize = 60-2*C.mult
	for i = 1, 4 do
		local bu = GroupFinderFrame["groupButton"..i]
		if bu then
			bu.ring:Hide()
			B.Reskin(bu, true)
			bu.bg:SetColorTexture(r, g, b, .25)
			bu.bg:SetInside(bu.__bg)

			bu.icon:SetPoint("LEFT", bu, "LEFT")
			bu.icon:SetSize(iconSize, iconSize)
			B.ReskinIcon(bu.icon)
		end
	end

	hooksecurefunc("GroupFinderFrame_SelectGroupButton", function(index)
		for i = 1, 4 do
			local button = GroupFinderFrame["groupButton"..i]
			if button and button.bg then
				if i == index then
					button.bg:Show()
				else
					button.bg:Hide()
				end
			end
		end
	end)

	B.ReskinPortraitFrame(PVEFrame)

	for i = 1, 3 do
		local tab = _G["PVEFrameTab"..i]
		if tab then
			B.ReskinTab(tab)
			if i ~= 1 then
				tab:ClearAllPoints()
				tab:SetPoint("TOPLEFT", _G["PVEFrameTab"..(i-1)], "TOPRIGHT", -15, 0)
			end
		end
	end

	-- LFDFrame
	hooksecurefunc("LFGDungeonListButton_SetDungeon", function(button)
		if not button.expandOrCollapseButton.styled then
			B.ReskinCheck(button.enableButton)
			B.ReskinCollapse(button.expandOrCollapseButton)

			button.expandOrCollapseButton.styled = true
		end

		button.enableButton:GetCheckedTexture():SetAtlas("checkmark-minimal")
		local disabledTexture = button.enableButton:GetDisabledCheckedTexture()
		disabledTexture:SetAtlas("checkmark-minimal")
		disabledTexture:SetDesaturated(true)
	end)

	B.StripTextures(LFDParentFrame)
	LFDQueueFrameBackground:Hide()
	B.SetBD(LFDRoleCheckPopup)
	LFDRoleCheckPopup.Border:Hide()
	B.Reskin(LFDRoleCheckPopupAcceptButton)
	B.Reskin(LFDRoleCheckPopupDeclineButton)
	B.ReskinTrimScroll(LFDQueueFrameSpecific.ScrollBar)
	B.ReskinTrimScroll(LFDQueueFrameRandomScrollFrame.ScrollBar)
	B.ReskinDropDown(LFDQueueFrameTypeDropdown)
	B.Reskin(LFDQueueFrameFindGroupButton)
	B.Reskin(LFDQueueFramePartyBackfillBackfillButton)
	B.Reskin(LFDQueueFramePartyBackfillNoBackfillButton)
	B.Reskin(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)
	styleRewardButton(LFDQueueFrameRandomScrollFrameChildFrameMoneyReward)

	-- LFGFrame
	hooksecurefunc("LFGRewardsFrame_SetItemButton", function(parentFrame, _, index)
		local parentName = parentFrame:GetName()
		styleRewardButton(parentFrame.MoneyReward)

		local button = _G[parentName.."Item"..index]
		styleRewardButton(button)
		styleRewardRole(button.roleIcon1)
		styleRewardRole(button.roleIcon2)
	end)

	hooksecurefunc("LFGDungeonReadyDialogReward_SetMisc", function(button)
		reskinDialogReward(button)
		button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
	end)

	hooksecurefunc("LFGDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex, rewardType, rewardArg)
		reskinDialogReward(button)

		local texturePath
		if rewardType == "reward" then
			texturePath = select(2, GetLFGDungeonRewardInfo(dungeonID, rewardIndex))
		elseif rewardType == "shortage" then
			texturePath = select(2, GetLFGDungeonShortageRewardInfo(dungeonID, rewardArg, rewardIndex))
		end
		if texturePath then
			button.texture:SetTexture(texturePath)
		end
	end)

	B.StripTextures(LFGDungeonReadyDialog, 0)
	B.SetBD(LFGDungeonReadyDialog)
	B.StripTextures(LFGInvitePopup)
	B.SetBD(LFGInvitePopup)
	B.StripTextures(LFGDungeonReadyStatus)
	B.SetBD(LFGDungeonReadyStatus)

	B.Reskin(LFGDungeonReadyDialogEnterDungeonButton)
	B.Reskin(LFGDungeonReadyDialogLeaveQueueButton)
	B.Reskin(LFGInvitePopupAcceptButton)
	B.Reskin(LFGInvitePopupDeclineButton)
	B.ReskinClose(LFGDungeonReadyDialogCloseButton)
	B.ReskinClose(LFGDungeonReadyStatusCloseButton)

	local roleButtons = {
		LFDQueueFrameRoleButtonTank,
		LFDRoleCheckPopupRoleButtonTank,
		RaidFinderQueueFrameRoleButtonTank,
		LFGInvitePopupRoleButtonTank,
		LFGListApplicationDialog.TankButton,
		LFGDungeonReadyStatusGroupedTank,

		LFDQueueFrameRoleButtonHealer,
		LFDRoleCheckPopupRoleButtonHealer,
		RaidFinderQueueFrameRoleButtonHealer,
		LFGInvitePopupRoleButtonHealer,
		LFGListApplicationDialog.HealerButton,
		LFGDungeonReadyStatusGroupedHealer,

		LFDQueueFrameRoleButtonDPS,
		LFDRoleCheckPopupRoleButtonDPS,
		RaidFinderQueueFrameRoleButtonDPS,
		LFGInvitePopupRoleButtonDPS,
		LFGListApplicationDialog.DamagerButton,
		LFGDungeonReadyStatusGroupedDamager,

		LFDQueueFrameRoleButtonLeader,
		RaidFinderQueueFrameRoleButtonLeader,
		LFGDungeonReadyStatusRolelessReady,
	}
	for _, roleButton in pairs(roleButtons) do
		B.ReskinRole(roleButton)
	end

	hooksecurefunc("SetCheckButtonIsRadio", function(button)
		button:SetNormalTexture(0)
		button:SetHighlightTexture(DB.bdTex)
		button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)
		button:SetPushedTexture(0)
		button:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		button:GetDisabledCheckedTexture():SetTexCoord(0, 1, 0, 1)
	end)

	hooksecurefunc("LFG_SetRoleIconIncentive", function(roleButton, incentiveIndex)
		if incentiveIndex then
			local tex
			if incentiveIndex == LFG_ROLE_SHORTAGE_PLENTIFUL then
				tex = "coin-copper"
			elseif incentiveIndex == LFG_ROLE_SHORTAGE_UNCOMMON then
				tex = "coin-silver"
			elseif incentiveIndex == LFG_ROLE_SHORTAGE_RARE then
				tex = "coin-gold"
			end
			roleButton.incentiveIcon.texture:SetInside()
			roleButton.incentiveIcon.texture:SetAtlas(tex)
		end

		updateRoleBonus(roleButton)
	end)

	hooksecurefunc("LFG_EnableRoleButton", updateRoleBonus)

	if ScenarioQueueFrame then
		B.StripTextures(ScenarioFinderFrame)
		ScenarioQueueFrameBackground:SetAlpha(0)
		B.ReskinDropDown(ScenarioQueueFrameTypeDropdown)
		B.Reskin(ScenarioQueueFrameFindGroupButton)
		B.ReskinTrimScroll(ScenarioQueueFrameRandomScrollFrame.ScrollBar)
		B.ReskinTrimScroll(ScenarioQueueFrameSpecific.ScrollBar)
	end
end)