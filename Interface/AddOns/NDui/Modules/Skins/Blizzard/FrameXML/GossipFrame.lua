local _, ns = ...
local B, C, L, DB = unpack(ns)

local gsub, strmatch = gsub, strmatch

local function replaceGossipFormat(button, textFormat, text)
	local newFormat, count = gsub(textFormat, "000000", "ffffff")
	if count > 0 then
		button:SetFormattedText(newFormat, text)
	end
end

local replacedGossipColor = {
	["000000"] = "ffffff",
	["414141"] = "7b8489", -- lighter color for some gossip options
}
local function replaceGossipText(button, text)
	if text and text ~= "" then
		local newText, count = gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59") -- replace icon texture
		if count > 0 then
			text = newText
			button:SetFormattedText("%s", text)
		end

		local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
		colorStr = replacedGossipColor[colorStr]
		if colorStr and rawText then
			button:SetFormattedText("|cff%s%s|r", colorStr, rawText)
		end
	end
end

tinsert(C.defaultThemes, function()
	if not NDuiDB["Skins"]["BlizzardSkins"] then return end

	QuestFont:SetTextColor(1, 1, 1)
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
	if GossipFrame.Background then GossipFrame.Background:Hide() end
	B.ReskinPortraitFrame(GossipFrame)
	B.Reskin(GossipFrameGreetingGoodbyeButton)
	B.ReskinScroll(GossipGreetingScrollFrameScrollBar)

	hooksecurefunc("GossipFrameUpdate", function()
		for button in GossipFrame.titleButtonPool:EnumerateActive() do
			if not button.styled then
				replaceGossipText(button, button:GetText())
				hooksecurefunc(button, "SetText", replaceGossipText)
				hooksecurefunc(button, "SetFormattedText", replaceGossipFormat)

				button.styled = true
			end
		end
	end)
end)