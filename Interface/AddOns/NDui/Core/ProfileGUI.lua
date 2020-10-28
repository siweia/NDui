local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")

local cr, cg, cb = DB.r, DB.g, DB.b
local myFullName = DB.MyFullName

-- Static popups
StaticPopupDialogs["RESET_NDUI"] = {
	text = L["Reset NDui Check"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		NDuiDB = {}
		NDuiADB = {}
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_RESET_PROFILE"] = {
	text = "你确定重置当前配置吗？",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		print("Reset current profile.")
		--wipe(C.db)
		--ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_APPLY_PROFILE"] = {
	text = "你确定载入所选配置吗？",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		print("Apply selected profile.")
		--NDuiADB["ProfileIndex"][myFullName] = G.currentProfile
		--ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_DOWNLOAD_PROFILE"] = {
	text = "你确定将所选配置替换你当前的配置吗？",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		print("Download selected profile.")
		--wipe(NDuiPDB[NDuiADB["ProfileIndex"][myFullName]])
		--NDuiPDB[NDuiADB["ProfileIndex"][myFullName]] = NDuiPDB[G.currentProfile]
		--ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_UPLOAD_PROFILE"] = {
	text = "你确定将当前使用的配置覆盖所选的配置吗？",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		print("Upload selected profile.")
		--wipe(NDuiPDB[G.currentProfile])
		--NDuiPDB[G.currentProfile] = C.db
	end,
	whileDead = 1,
}

function G:CreateProfileIcon(bar, index, texture, title, description)
	local button = CreateFrame("Button", nil, bar)
	button:SetSize(32, 32)
	button:SetPoint("RIGHT", -5 - (index-1)*37, 0)
	B.PixelIcon(button, texture, true)
	button.title = title
	B.AddTooltip(button, "ANCHOR_RIGHT", description, "info")

	return button
end

function G:Reset_OnClick()
	StaticPopup_Show("NDUI_RESET_PROFILE")
end

function G:Apply_OnClick()
	G.currentProfile = self:GetParent().index
	StaticPopup_Show("NDUI_APPLY_PROFILE")
end

function G:Download_OnClick()
	G.currentProfile = self:GetParent().index
	StaticPopup_Show("NDUI_DOWNLOAD_PROFILE")
end

function G:Upload_OnClick()
	G.currentProfile = self:GetParent().index
	StaticPopup_Show("NDUI_UPLOAD_PROFILE")
end

function G:CreateProfileBar(parent, index)
	local bar = B.CreateBDFrame(parent, .25)
	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", 10, -10 - 45*(index-1))
	bar:SetSize(570, 40)
	bar.index = index
	
	local icon = CreateFrame("Frame", nil, bar)
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", 5, 0)
	if index == 1 then
		B.PixelIcon(icon, nil, true) -- character
		SetPortraitTexture(icon.Icon, "player")
	else
		B.PixelIcon(icon, 235423, true) -- share
		icon.Icon:SetTexCoord(.6, .9, .1, .4)
	end

	local note = B.CreateEditBox(bar, 150, 32)
	note:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	note:SetMaxLetters(20)
	if index == 1 then
		note:SetText("角色配置")
	else
		note:SetText("共享配置"..(index - 1))
	end
	note.title = "配置名称"
	B.AddTooltip(note, "ANCHOR_TOP", "|n自定义你的配置名称。", "info")

	local reset = G:CreateProfileIcon(bar, 1, "Atlas:transmog-icon-revert", "重置当前配置", "|n重置当前配置，并载入默认设置，需要重载插件后生效。")
	reset:SetScript("OnClick", G.Reset_OnClick)
	bar.reset = reset

	local apply = G:CreateProfileIcon(bar, 2, "Interface\\RAIDFRAME\\ReadyCheck-Ready", "启用所选配置", "|n切换至所选配置，需要重载插件后生效。")
	apply:SetScript("OnClick", G.Apply_OnClick)
	bar.apply = apply

	local download = G:CreateProfileIcon(bar, 3, "Atlas:streamcinematic-downloadicon", "替换当前配置", "|n读取所选配置，并覆盖你当前使用的配置，需要重载插件后生效。")
	download.Icon:SetTexCoord(.25, .75, .25, .75)
	download:SetScript("OnClick", G.Download_OnClick)
	bar.download = download

	local upload = G:CreateProfileIcon(bar, 4, "Atlas:bags-icon-addslots", "覆盖所选配置", "|n将你当前使用的配置，覆盖到所选配置栏位。")
	upload.Icon:SetInside(nil, 6, 6)
	upload:SetScript("OnClick", G.Upload_OnClick)
	bar.upload = upload

	return bar
end

local function UpdateButtonStatus(button, enable)
	button:EnableMouse(enable)
	button.Icon:SetDesaturated(not enable)
end

function G:UpdateCurrentProfile()
	for index, bar in pairs(G.bars) do
		if index == G.currentProfile then
			UpdateButtonStatus(bar.upload, false)
			UpdateButtonStatus(bar.download, false)
			UpdateButtonStatus(bar.apply, false)
			UpdateButtonStatus(bar.reset, true)
			bar:SetBackdropColor(cr, cg, cb, .25)
			bar.apply.bg:SetBackdropBorderColor(1, .8, 0)
		else
			UpdateButtonStatus(bar.upload, true)
			UpdateButtonStatus(bar.download, true)
			UpdateButtonStatus(bar.apply, true)
			UpdateButtonStatus(bar.reset, false)
			bar:SetBackdropColor(0, 0, 0, .25)
			bar.apply.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end
end

function G:CreateProfileGUI(parent)
	local reset = B.CreateButton(parent, 120, 24, L["NDui Reset"])
	reset:SetPoint("BOTTOMRIGHT", -10, 10)
	reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI")
	end)

	local import = B.CreateButton(parent, 120, 24, L["Import"])
	import:SetPoint("BOTTOMLEFT", 10, 10)
	import:SetScript("OnClick", function()
		f:Hide()
		createDataFrame()
		dataFrame.Header:SetText(L["Import Header"])
		dataFrame.text:SetText(L["Import"])
		dataFrame.editBox:SetText("")
	end)

	local export = B.CreateButton(parent, 120, 24, L["Export"])
	export:SetPoint("LEFT", import, "RIGHT", 3, 0)
	export:SetScript("OnClick", function()
		f:Hide()
		createDataFrame()
		dataFrame.Header:SetText(L["Export Header"])
		dataFrame.text:SetText(OKAY)
		G:ExportGUIData()
	end)

	B.CreateFS(parent, 14, "配置管理", "system", "TOPLEFT", 10, -10)
	local text = "你可以在这里管理你的插件配置。默认是基于你的角色进行存储，不进行账号之间的共享。你也可以切换到共享配置，这样多个角色就可以使用同一个设置，而无需进行配置的导入和导出。"
	local description = B.CreateFS(parent, 14, text, nil, "TOPLEFT", 10, -35)
	description:SetPoint("TOPRIGHT", -10, -30)
	description:SetWordWrap(true)
	description:SetJustifyH("LEFT")

	G.currentProfile = 1

	local numBars = 6
	local panel = B.CreateBDFrame(parent, .25)
	panel:ClearAllPoints()
	panel:SetPoint("BOTTOMLEFT", 10, 80)
	panel:SetWidth(parent:GetWidth() - 20)
	panel:SetHeight(15 + numBars*45)
	panel:SetFrameLevel(11)

	G.bars = {}
	for i = 1, numBars do
		G.bars[i] = G:CreateProfileBar(panel, i)
	end

	G:UpdateCurrentProfile()
end