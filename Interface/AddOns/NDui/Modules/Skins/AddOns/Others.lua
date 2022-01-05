local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local _G = _G
local strfind = strfind
local cr, cg, cb = DB.r, DB.g, DB.b

function S:FriendGroups()
	if not IsAddOnLoaded("FriendGroups") then return end

	if FriendGroups_UpdateFriendButton then
		local function replaceButtonStatus(self, texture)
			self:SetPoint("TOPLEFT", 4, 1)
			self.bg:Show()
			if strfind(texture, "PlusButton") then
				self:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse", true)
			elseif strfind(texture, "MinusButton") then
				self:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand", true)
			else
				self:SetPoint("TOPLEFT", 4, -3)
				self.bg:Hide()
			end
		end

		hooksecurefunc("FriendGroups_UpdateFriendButton", function(button)
			if not button.styled then
				local bg = B.CreateBDFrame(button.status, .25)
				bg:SetInside(button.status, 3, 3)
				button.status.bg = bg
				hooksecurefunc(button.status, "SetTexture", replaceButtonStatus)

				button.styled = true
			end
		end)
	end
end

function S:PostalSkin()
	if not IsAddOnLoaded("Postal") then return end
	if not PostalOpenAllButton then return end -- outdate postal

	B.Reskin(PostalSelectOpenButton)
	B.Reskin(PostalSelectReturnButton)
	B.Reskin(PostalOpenAllButton)
	B.ReskinArrow(Postal_ModuleMenuButton, "down")
	B.ReskinArrow(Postal_OpenAllMenuButton, "down")
	B.ReskinArrow(Postal_BlackBookButton, "down")
	for i = 1, 7 do
		B.ReskinCheck(_G["PostalInboxCB"..i])
	end

	Postal_ModuleMenuButton:ClearAllPoints()
	Postal_ModuleMenuButton:SetPoint("RIGHT", MailFrame.CloseButton, "LEFT", -2, 0)
	Postal_OpenAllMenuButton:SetPoint("LEFT", PostalOpenAllButton, "RIGHT", 2, 0)
	Postal_BlackBookButton:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)
end

function S:SoulbindsTalents()
	if not IsAddOnLoaded("SoulbindsTalents") then return end

	hooksecurefunc("PanelTemplates_SetNumTabs", function(frame, num)
		if frame == _G.PlayerTalentFrame and num == 4 then
			if _G.PlayerTalentFrameTab4 then
				B.ReskinTab(_G.PlayerTalentFrameTab4)
			end
		elseif frame == _G.SoulbindAnchor then
			for i = 1, 4 do
				local tab = _G["SoulbindViewerTab"..i]
				if tab then
					B.ReskinTab(tab)
				end
			end
		end
	end)
end

local function restyleMRTWidget(self)
	local iconTexture = self.iconTexture
	local bar = self.statusbar
	local parent = self.parent
	local width = parent.barWidth or 100
	local mult = (parent.iconSize or 24) + 5
	local offset = 3

	if not self.styled then
		B.SetBD(iconTexture)
		self.__bg = B.SetBD(bar)
		self.background:SetAllPoints(bar)

		self.styled = true
	end
	iconTexture:SetTexCoord(unpack(DB.TexCoord))
	self.__bg:SetShown(parent.optionAlphaTimeLine ~= 0)

	if parent.optionIconPosition == 3 or parent.optionIconTitles then
		self.statusbar:SetPoint("RIGHT", self, -offset, 0)
		mult = 0
	elseif parent.optionIconPosition == 2 then
		self.icon:SetPoint("RIGHT", self, -offset, 0)
		self.statusbar:SetPoint("LEFT", self, offset, 0)
		self.statusbar:SetPoint("RIGHT", self, -mult, 0)
	else
		self.icon:SetPoint("LEFT", self, offset, 0)
		self.statusbar:SetPoint("LEFT", self, mult, 0)
		self.statusbar:SetPoint("RIGHT", self, -offset, 0)
	end

	self.timeline.width = width - mult - offset
	self.timeline:SetWidth(self.timeline.width)
	self.border.top:Hide()
	self.border.bottom:Hide()
	self.border.left:Hide()
	self.border.right:Hide()
end

local MRTLoaded
local function LoadMRTSkin()
	if MRTLoaded then return end
	MRTLoaded = true

	local name = "MRTRaidCooldownCol"
	for i = 1, 10 do
		local column = _G[name..i]
		local lines = column and column.lines
		if lines then
			for j = 1, #lines do
				local line = lines[j]
				if line.UpdateStyle then
					hooksecurefunc(line, "UpdateStyle", restyleMRTWidget)
					line:UpdateStyle()
				end
			end
		end
	end
end

function S:MRT_Skin()
	if not IsAddOnLoaded("MRT") then return end

	local isEnabled = VMRT and VMRT.ExCD2 and VMRT.ExCD2.enabled
	if isEnabled then
		LoadMRTSkin()
	else
		hooksecurefunc(MRTOptionsFrameExCD2, "Load", function(self)
			if self.chkEnable then
				self.chkEnable:HookScript("OnClick", LoadMRTSkin)
			end
		end)
	end

	-- Consumables
	local buttons = MRTConsumables and MRTConsumables.buttons
	if buttons then
		for i = 1, 8 do
			local button = buttons[i]
			local icon = button and button.texture
			if icon then
				B.ReskinIcon(icon)
			end
		end
	end
end

local function updateSoulshapeButtons(self)
	local buttons = self.buttons
	for i = 1, #buttons do
		local bu = buttons[i]
		if not bu.bg then
			local bg = B.CreateBDFrame(bu, .25)
			bg:SetPoint("TOPLEFT", 3, -1)
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			bu.bg = bg

			B.ReskinIcon(bu.icon)
			bu.selectedTexture:SetAlpha(0)
			bu.background:SetTexture(nil)
			bu:SetHighlightTexture(nil)

			local critterIcon = bu.critterIcon
			critterIcon:SetTexture("Interface\\ICONS\\Pet_Type_Critter")
			critterIcon:SetTexCoord(0, 1, 0, 1)
			critterIcon:SetSize(40, 40)
			critterIcon:SetAlpha(.5)
		end

		if bu.selected then
			bu.bg:SetBackdropColor(cr, cg, cb, .25)
		else
			bu.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end
end

function S:SoulshapeJournal()
	if not IsAddOnLoaded("SoulshapeJournal") then return end
	if not SoulshapeCollectionPanel then return end

	CollectionsJournalCoverTab:SetAlpha(0)
	B.ReskinTab(CollectionsJournalSecureTab0)

	local styled
	SoulshapeCollectionPanel:HookScript("OnShow", function(frame)
		if styled then return end
		styled = true

		B.StripTextures(frame)
		B.SetBD(frame, 1) -- on top of mount journal
		B.ReskinClose(frame.CloseButton)
		B.ReskinScroll(frame.ScrollFrame.ScrollBar)
		B.ReskinArrow(frame.SoulshapeDisplay.ModelScene.RotateLeftButton, "left")
		B.ReskinArrow(frame.SoulshapeDisplay.ModelScene.RotateRightButton, "right")
		B.StripTextures(SoulshapeCollectionPanelCount)
		B.CreateBDFrame(SoulshapeCollectionPanelCount, .25)

		local searchBox, _, filterButton = select(9, frame:GetChildren())
		B.ReskinInput(searchBox)
		filterButton.Icon = select(12, filterButton:GetRegions())
		if filterButton.Icon then
			B.ReskinFilterButton(filterButton)
		end

		hooksecurefunc(frame.ScrollFrame, "update", updateSoulshapeButtons)
		hooksecurefunc(frame.ScrollFrame, "UpdateButtons", updateSoulshapeButtons)
	end)
end

function S:OtherSkins()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	S:FriendGroups()
	S:PostalSkin()
	S:SoulbindsTalents()
	S:MRT_Skin()
	S:SoulshapeJournal()
end