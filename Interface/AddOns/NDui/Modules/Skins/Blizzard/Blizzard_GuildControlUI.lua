local _, ns = ...
local B, C, L, DB = unpack(ns)

local function updateGuildRanks()
	for i = 1, GuildControlGetNumRanks() do
		local rank = _G["GuildControlUIRankOrderFrameRank"..i]
		if not rank.styled then
			rank.upButton.icon:Hide()
			rank.downButton.icon:Hide()
			rank.deleteButton.icon:Hide()

			B.ReskinArrow(rank.upButton, "up")
			B.ReskinArrow(rank.downButton, "down")
			B.ReskinClose(rank.deleteButton)
			B.ReskinInput(rank.nameBox, 20)

			rank.styled = true
		end
	end
end

C.themes["Blizzard_GuildControlUI"] = function()
	local r, g, b = DB.r, DB.g, DB.b

	B.SetBD(GuildControlUI)

	for i = 1, 9 do
		select(i, GuildControlUI:GetRegions()):Hide()
	end

	for i = 1, 8 do
		select(i, GuildControlUIRankBankFrameInset:GetRegions()):Hide()
	end

	GuildControlUIRankSettingsFrameOfficerBg:SetAlpha(0)
	GuildControlUIRankSettingsFrameRosterBg:SetAlpha(0)
	GuildControlUIRankSettingsFrameBankBg:SetAlpha(0)
	GuildControlUITopBg:Hide()
	GuildControlUIHbar:Hide()
	GuildControlUIRankBankFrameInsetScrollFrameTop:SetAlpha(0)
	GuildControlUIRankBankFrameInsetScrollFrameBottom:SetAlpha(0)

	-- Guild ranks
	B:RegisterEvent("GUILD_RANKS_UPDATE", updateGuildRanks)
	hooksecurefunc("GuildControlUI_RankOrder_Update", updateGuildRanks)

	-- Guild tabs
	local checkboxes = {"viewCB", "depositCB"}
	hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
		for i = 1, GetNumGuildBankTabs() + 1 do
			local tab = "GuildControlBankTab"..i
			local bu = _G[tab]
			if bu and not bu.styled then
				local ownedTab = bu.owned

				_G[tab.."Bg"]:Hide()
				B.ReskinIcon(ownedTab.tabIcon)
				B.CreateBDFrame(bu, .25)
				B.Reskin(bu.buy.button)
				B.ReskinInput(ownedTab.editBox)

				for _, name in pairs(checkboxes) do
					local box = ownedTab[name]
					box:SetNormalTexture(DB.blankTex)
					box:SetPushedTexture(DB.blankTex)
					box:SetHighlightTexture(DB.bdTex)

					local check = box:GetCheckedTexture()
					check:SetDesaturated(true)
					check:SetVertexColor(r, g, b)

					local bg = B.CreateBDFrame(box, 0, true)
					bg:SetInside(box, 4, 4)

					local hl = box:GetHighlightTexture()
					hl:SetInside(bg)
					hl:SetVertexColor(r, g, b, .25)
				end

				bu.styled = true
			end
		end
	end)

	B.ReskinCheck(GuildControlUIRankSettingsFrameOfficerCheckbox)
	for i = 1, 20 do
		local checbox = _G["GuildControlUIRankSettingsFrameCheckbox"..i]
		if checbox then
			B.ReskinCheck(checbox)
		end
	end

	B.Reskin(GuildControlUIRankOrderFrameNewButton)
	B.ReskinClose(GuildControlUICloseButton)
	B.ReskinScroll(GuildControlUIRankBankFrameInsetScrollFrameScrollBar)
	B.ReskinDropDown(GuildControlUINavigationDropDown)
	B.ReskinDropDown(GuildControlUIRankSettingsFrameRankDropDown)
	B.ReskinDropDown(GuildControlUIRankBankFrameRankDropDown)
	B.ReskinInput(GuildControlUIRankSettingsFrameGoldBox, 20)
end