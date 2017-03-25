local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	local function moveNavButtons(self)
		local width = 0
		local collapsedWidth
		local maxWidth = self:GetWidth() - self.widthBuffer

		local lastShown
		local collapsed = false

		for i = #self.navList, 1, -1 do
			local currentWidth = width
			width = width + self.navList[i]:GetWidth()

			if width > maxWidth then
				collapsed = true
				if not collapsedWidth then
					collapsedWidth = currentWidth
				end
			else
				if lastShown then
					self.navList[lastShown]:SetPoint("LEFT", self.navList[i], "RIGHT", 1, 0)
				end
				lastShown = i
			end
		end

		if collapsed then
			if collapsedWidth + self.overflowButton:GetWidth() > maxWidth then
				lastShown = lastShown + 1
			end

			if lastShown then
				local lastButton = self.navList[lastShown]

				if lastButton then
					lastButton:SetPoint("LEFT", self.overflowButton, "RIGHT", 1, 0)
				end
			end
		end
	end

	hooksecurefunc("NavBar_Initialize", F.ReskinNavBar)

	hooksecurefunc("NavBar_AddButton", function(self, buttonData)
		local navButton = self.navList[#self.navList]

		if not navButton.restyled then
			F.Reskin(navButton)

			navButton.arrowUp:SetAlpha(0)
			navButton.arrowDown:SetAlpha(0)

			navButton.selected:SetDrawLayer("BACKGROUND", 1)
			navButton.selected:SetColorTexture(r, g, b, .3)

			navButton:HookScript("OnClick", function()
				moveNavButtons(self)
			end)

			-- arrow button

			local arrowButton = navButton.MenuArrowButton

			arrowButton.Art:Hide()

			arrowButton:SetHighlightTexture("")

			local tex = arrowButton:CreateTexture(nil, "ARTWORK")
			tex:SetTexture(C.media.arrowDown)
			tex:SetSize(8, 8)
			tex:SetPoint("CENTER")
			arrowButton.bgTex = tex

			local colourArrow, clearArrow = F.colourArrow, F.clearArrow
			arrowButton:SetScript("OnEnter", colourArrow)
			arrowButton:SetScript("OnLeave", clearArrow)

			navButton.restyled = true
		end

		moveNavButtons(self)
	end)
end)