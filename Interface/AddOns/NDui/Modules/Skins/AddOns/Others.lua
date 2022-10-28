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
	B.Reskin(PostalForwardButton)
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

	for i = 1, 16 do
		local button = _G["Postal_QuickAttachButton"..i]
		if button then
			button:GetNormalTexture():SetAlpha(0)
			button:GetPushedTexture():SetAlpha(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			B.ReskinIcon(button.icon)
		end
	end
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
			bu:SetHighlightTexture(0)

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

function S:ATT()
	if not IsAddOnLoaded("AllTheThings") then return end

	local ATT = _G.AllTheThings
	if not ATT then return end

	local function reskinATTWindow(frame)
		if not frame or frame.styled then return end

		B.SetBD(frame, nil, 2, -2, -2, 2)
		B.ReskinClose(frame.CloseButton, nil, -4, -4)
		B.ReskinScroll(frame.ScrollBar)
		frame.Grip:SetTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
		local up = frame.ScrollBar:GetChildren()
		up:ClearAllPoints()
		up:SetPoint("TOPRIGHT", 0, 10)

		frame.styled = true
	end

	for _, frame in pairs(ATT.Windows) do
		reskinATTWindow(frame)
	end

	hooksecurefunc(ATT, "GetWindow", function(self, suffix)
		reskinATTWindow(self.Windows[suffix])
	end)
end

function S:TrinketMenu()
	if not IsAddOnLoaded("TrinketMenu") then return end

	local function reskinFrame(frame)
		if not frame then return end
		B.StripTextures(frame)
		B.SetBD(frame):SetInside(nil, 3, 3)
	end

	local function reskinButton(name)
		local button = _G[name]
		if not button then return end

		button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
		button:SetPushedTexture(DB.textures.pushed)
		button:GetCheckedTexture():SetColorTexture(1, .8, 0, .5)
		_G[name.."NormalTexture"]:SetAlpha(0)
		B.ReskinIcon(_G[name.."Icon"])

		local queue = _G[name.."Queue"]
		if queue then queue:SetTexCoord(unpack(DB.TexCoord)) end
	end

	reskinFrame(TrinketMenu_MainFrame)
	reskinButton("TrinketMenu_Trinket0")
	reskinButton("TrinketMenu_Trinket1")

	reskinFrame(TrinketMenu_MenuFrame)
	for i = 1, 30 do
		reskinButton("TrinketMenu_Menu"..i)
	end
end

function S:ERT()
	if not IsAddOnLoaded("EchoRaidTools") then return end

	local function reskinTab(tab)
		local bg = B.SetBD(tab)
		bg:SetInside(tab, 2, 2)

		tab:SetNormalTexture(0)
		tab:SetPushedTexture(0)
		tab:SetDisabledTexture(0)
		local hl = tab:GetHighlightTexture()
		hl:SetColorTexture(cr, cg, cb, .2)
		hl:SetInside(bg)
	end

	local function resetButtonBG(self)
		self.__button:GetScript("OnLeave")(self.__button)
	end

	S:RegisterSkin("Blizzard_EncounterJournal", function()
		local encounterInfo = EncounterJournal.encounter.info
		local ERTTab, ERTFrame

		for i = encounterInfo:GetNumChildren(), 1, -1 do
			if ERTTab and ERTFrame then break end

			local child = select(i, encounterInfo:GetChildren())
			if child.unSelected then
				ERTTab = child
			elseif child.scrollframe then
				ERTFrame = child
			end
		end

		reskinTab(ERTTab)
		B.ReskinScroll(ERTFrame.scrollframe.ScrollBar)

		local scrollChild = ERTFrame.scrollframe:GetScrollChild()

		hooksecurefunc(scrollChild, "SetHeight", function(self)
			for i = self:GetNumChildren(), 1, -1 do
				local header = select(i, self:GetChildren())
				if not header.styled then
					for i = 5, 19 do
						select(i, header.button:GetRegions()):SetTexture("")
					end
					B.Reskin(header.button)
					header.descriptionBG:SetAlpha(0)
					header.descriptionBGBottom:SetAlpha(0)
					header.description:SetTextColor(1, 1, 1)
					header.button.label:SetTextColor(1, 1, 1)
					header.button.label.SetTextColor = B.Dummy
					header.button.expandIcon:SetWidth(20) -- don't wrap the text
					header.button.waIconbg = B.ReskinIcon(header.button.waIcon)
					header.glowAnimation.__button = header.button
					header.glowAnimation:HookScript("OnPlay", resetButtonBG)

					header.styled = true
				end

				header.button.waIconbg:SetShown(header.button.waIcon:IsShown())
			end
		end)
	end)
end

function S:PSFJ()
	if not IsAddOnLoaded("ProtoformSynthesisFieldJournal") then return end

	local frame = _G.ProtoformSynthesisFieldJournal
	B.StripTextures(frame)
	B.SetBD(frame)

	B.ReskinClose(frame.CloseButton)
	B.ReskinTab(frame.PanelTabs.PetTab)
	B.ReskinTab(frame.PanelTabs.MountTab)
	B.ReskinTab(frame.PanelTabs.SettingsTab)

	local function handlePSFJScroll(scrollBar)
		B.ReskinScroll(scrollBar)
		S.ReskinScrollEnd(scrollBar.TopButton, "up")
		S.ReskinScrollEnd(scrollBar.BottomButton, "down")
	end

	frame.List.Background:Hide()
	handlePSFJScroll(frame.List.ScrollFrame.ScrollBar)
	frame.Settings.Background:Hide()
	handlePSFJScroll(frame.Settings.ScrollFrame.ScrollBar)

	local function onEnter(button)
		button.bg:SetBackdropBorderColor(0, .6, 1)
	end

	local function onLeave(button)
		button.bg:SetBackdropBorderColor(0, 0, 0)
	end

	hooksecurefunc(frame.List, "Update", function(self)
		local buttons = self.ScrollFrame.Buttons
		if buttons then
			for i = 1, #buttons do
				local button = buttons[i]
				if not button.styled then
					button:HideBackdrop()
					button.bg = B.CreateBDFrame(button, .25)
					button.bg:SetInside(nil, 2, 2)
					button:HookScript("OnEnter", onEnter)
					button:HookScript("OnLeave", onLeave)

					button.styled = true
				end
			end
		end
	end)

	local done
	hooksecurefunc(frame.Settings, "Update", function(self)
		if done then return end
		done = true

		local buttons = self.ScrollFrame.Buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if button.CheckButton then
				B.ReskinCheck(button.CheckButton)
			end
		end
	end)
end

function S:TLDR()
	if not IsAddOnLoaded("TLDRMissions") then return end

	local function reskinUIElements(frame)
		for i = 1, frame:GetNumChildren() do
			local child = select(i, frame:GetChildren())
			if child:IsObjectType("CheckButton") then
				B.ReskinCheck(child)
				child:SetSize(24, 24)
			elseif child:IsObjectType("Button") then
				B.Reskin(child)
			elseif child:IsObjectType("Slider") then
				B.ReskinSlider(child)
			elseif child:IsObjectType("EditBox") then
				B.ReskinEditBox(child)
			elseif child:IsObjectType("Frame") and child.Button then
				B.StripTextures(child)
				B.ReskinArrow(child.Button, "down")
			end
		end
	end

	B.StripTextures(TLDRMissionsFrame)
	B.ReskinClose(TLDRMissionsFrame.CloseButton)
	B.SetBD(TLDRMissionsFrame):SetInside(nil, 2, 2)
	B.Reskin(TLDRMissionsToggleButton)

	reskinUIElements(TLDRMissionsFrameMainPanel)
	reskinUIElements(TLDRMissionsFrameAdvancedPanel)

	B.ReskinTab(TLDRMissionsFrameTab1)
	B.ReskinTab(TLDRMissionsFrameTab2)
	B.ReskinTab(TLDRMissionsFrameTab3)
end

function S:OtherSkins()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	S:FriendGroups()
	C_Timer.After(1, S.PostalSkin)
	S:SoulbindsTalents()
	S:MRT_Skin()
	S:SoulshapeJournal()
	S:ATT()
	S:TrinketMenu()
	S:ERT()
	S:PSFJ()
	S:TLDR()
end