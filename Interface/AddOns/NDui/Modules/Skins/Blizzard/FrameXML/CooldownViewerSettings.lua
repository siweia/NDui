local _, ns = ...
local B, C, L, DB = unpack(ns)
local cr, cg, cb = DB.r, DB.g, DB.b

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local frame = CooldownViewerSettings
	B.ReskinPortraitFrame(frame)
	B.ReskinEditBox(frame.SearchBox)
	B.ReskinTrimScroll(frame.CooldownScroll.ScrollBar)
	B.ReskinDropDown(frame.LayoutDropdown)
	B.Reskin(frame.UndoButton)

	-- Side tabs
	local function reskinSideTab(tab)
		if not tab then return end

		B.StripTextures(tab, 2)
		tab.bg = B.SetBD(tab)
		tab.bg:SetInside(nil, 2, 2)
		local hl = tab:CreateTexture(nil, "HIGHLIGHT")
		hl:SetColorTexture(1, 1, 1, .25)
		hl:SetInside(tab.bg)

		tab.SelectedTexture:SetDrawLayer("BACKGROUND")
		tab.SelectedTexture:SetColorTexture(cr, cg, cb, .25)
		tab.SelectedTexture:SetInside(tab.bg)
	end

	for _, tab in ipairs(frame.TabButtons) do
		reskinSideTab(tab)
	end

	local oldAtlas = {
		["Options_ListExpand_Right"] = 1,
		["Options_ListExpand_Right_Expanded"] = 2,
	}
	local function updateCollapse(texture, atlas)
		if oldAtlas[atlas] == 1 then
			texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
		else
			texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
		end
	end

	local function updateButtons(frame)
		for button in frame.itemPool:EnumerateActive() do
			if not button.styled then
				B.ReskinIcon(button.Icon)
				button.Highlight:SetColorTexture(1, 1, 1, .25)
				button.styled = true
			end
		end

		local header = frame.Header
		if header and not header.styled then
			B.StripTextures(header)

			if header.Right then
				B.StripTextures(header)
				hooksecurefunc(header.Right, "SetAtlas", updateCollapse)
				hooksecurefunc(header.HighlightRight, "SetAtlas", updateCollapse)
				updateCollapse(header.Right)
				updateCollapse(header.HighlightRight)
				B.CreateBDFrame(header, .25):SetInside(nil, 2, 2)
			end
			header.styled = true
		end
	end

	hooksecurefunc(frame, "RefreshLayout", function(self)
		for categoryDisplay in self.categoryPool:EnumerateActive() do
			if not categoryDisplay.styled then
				updateButtons(categoryDisplay)
				hooksecurefunc(categoryDisplay, "RefreshLayout", updateButtons)
				categoryDisplay.styled = true
			end
		end
	end)
end)