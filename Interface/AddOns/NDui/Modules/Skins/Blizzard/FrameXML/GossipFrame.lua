local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local gsub = string.gsub
	NORMAL_QUEST_DISPLAY = gsub(NORMAL_QUEST_DISPLAY, "000000", "ffffff")
	TRIVIAL_QUEST_DISPLAY = gsub(TRIVIAL_QUEST_DISPLAY, "000000", "ffffff")
	IGNORED_QUEST_DISPLAY = gsub(IGNORED_QUEST_DISPLAY, "000000", "ffffff")

	GossipGreetingText:SetTextColor(1, 1, 1)
	NPCFriendshipStatusBar:GetRegions():Hide()
	NPCFriendshipStatusBarNotch1:SetColorTexture(0, 0, 0)
	NPCFriendshipStatusBarNotch1:SetSize(1, 16)
	NPCFriendshipStatusBarNotch2:SetColorTexture(0, 0, 0)
	NPCFriendshipStatusBarNotch2:SetSize(1, 16)
	NPCFriendshipStatusBarNotch3:SetColorTexture(0, 0, 0)
	NPCFriendshipStatusBarNotch3:SetSize(1, 16)
	NPCFriendshipStatusBarNotch4:SetColorTexture(0, 0, 0)
	NPCFriendshipStatusBarNotch4:SetSize(1, 16)
	select(7, NPCFriendshipStatusBar:GetRegions()):Hide()
	NPCFriendshipStatusBar.icon:SetPoint("TOPLEFT", -30, 7)
	B.CreateBDFrame(NPCFriendshipStatusBar, .25)

	GossipFrameInset:Hide()
	B.ReskinPortraitFrame(GossipFrame)
	B.Reskin(GossipFrameGreetingGoodbyeButton)
	B.ReskinScroll(GossipGreetingScrollFrameScrollBar)

	local function resetFontString()
		local index = 1
		local titleButton = _G["GossipTitleButton"..index]
		while titleButton do
			if titleButton:GetText() ~= nil then
				titleButton:SetText(gsub(titleButton:GetText(), ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59"))
			end
			index = index + 1
			titleButton = _G["GossipTitleButton"..index]
		end
	end

	GossipFrame:HookScript("OnShow", function()
		C_Timer.After(.01, resetFontString)
	end)
end)