local _, ns = ...
local B, C, L, DB = unpack(ns)

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local r, g, b = DB.r, DB.g, DB.b

	local LootHistoryFrame = GroupLootHistoryFrame or LootHistoryFrame
	if not LootHistoryFrame then return end

	B.StripTextures(LootHistoryFrame)
	B.SetBD(LootHistoryFrame)
	B.ReskinClose(LootHistoryFrame.ClosePanelButton)
	B.ReskinTrimScroll(LootHistoryFrame.ScrollBar)
	B.ReskinDropDown(LootHistoryFrame.EncounterDropDown)

	local bar = LootHistoryFrame.Timer
	B.StripTextures(bar)
	B.CreateBDFrame(bar, .25)
	bar.Fill:SetTexture(DB.normTex)
	bar.Fill:SetVertexColor(r, g, b)

	-- [[ Resize button ]]

	B.StripTextures(LootHistoryFrame.ResizeButton)
	LootHistoryFrame.ResizeButton:SetHeight(8)

	do
		local line1 = LootHistoryFrame.ResizeButton:CreateTexture()
		line1:SetTexture(DB.bdTex)
		line1:SetVertexColor(.7, .7, .7)
		line1:SetSize(30, C.mult)
		line1:SetPoint("TOP", 0, -2)

		local line2 = LootHistoryFrame.ResizeButton:CreateTexture()
		line2:SetTexture(DB.bdTex)
		line2:SetVertexColor(.7, .7, .7)
		line2:SetSize(30, C.mult)
		line2:SetPoint("TOP", 0, -5)

		LootHistoryFrame.ResizeButton:HookScript("OnEnter", function()
			line1:SetVertexColor(r, g, b)
			line2:SetVertexColor(r, g, b)
		end)

		LootHistoryFrame.ResizeButton:HookScript("OnLeave", function()
			line1:SetVertexColor(.7, .7, .7)
			line2:SetVertexColor(.7, .7, .7)
		end)
	end

	-- [[ Item frame ]]

	local function ReskinLootButton(button)
		if not button.styled then
			if button.NameFrame then
				button.NameFrame:SetAlpha(0)
			end
			if button.BorderFrame then
				button.BorderFrame:SetAlpha(0)
				B.CreateBDFrame(button.BorderFrame, .25)
			end

			local item = button.Item
			if item then
				B.StripTextures(item, 1)
				item.bg = B.ReskinIcon(item.icon)
				item.bg:SetFrameLevel(item.bg:GetFrameLevel() + 1)
				B.ReskinIconBorder(item.IconBorder, true)
			end

			button.styled = true
		end
	end

	hooksecurefunc(LootHistoryFrame.ScrollBox, "Update", function(self)
		self:ForEachFrame(ReskinLootButton)
	end)
end)