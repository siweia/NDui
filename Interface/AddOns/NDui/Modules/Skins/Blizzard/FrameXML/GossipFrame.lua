local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	local gsub = string.gsub

	NORMAL_QUEST_DISPLAY = gsub(NORMAL_QUEST_DISPLAY, "000000", "ffffff")
	TRIVIAL_QUEST_DISPLAY = gsub(TRIVIAL_QUEST_DISPLAY, "000000", "ffffff")
	IGNORED_QUEST_DISPLAY = gsub(IGNORED_QUEST_DISPLAY, "000000", "ffffff")
	GossipGreetingText:SetTextColor(1, 1, 1)

	NPCFriendshipStatusBar.icon:SetPoint("TOPLEFT", -30, 7)
	B.StripTextures(NPCFriendshipStatusBar)
	NPCFriendshipStatusBar:SetStatusBarTexture(DB.normTex)
	B.CreateBDFrame(NPCFriendshipStatusBar, .25)

	for i = 1, 4 do
		local notch = _G["NPCFriendshipStatusBarNotch"..i]
		if notch then
			notch:SetColorTexture(0, 0, 0)
			notch:SetSize(C.mult, 16)
		end
	end

	GossipFrameInset:Hide()
	GossipFrame.Background:Hide()
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
	hooksecurefunc("GossipFrameUpdate", resetFontString)
end)