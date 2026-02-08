local _, ns = ...
local B, C, L, DB = unpack(ns)
local G = B:GetModule("GUI")

local pairs, strsplit, Ambiguate = pairs, strsplit, Ambiguate
local strfind, tostring, select = strfind, tostring, select
local SetPortraitTexture, StaticPopup_Show = SetPortraitTexture, StaticPopup_Show
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
		NDuiPDB = {}
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["RESET_NDUI_HELPINFO"] = {
	text = L["Reset NDui Helpinfo"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(NDuiADB["Help"])
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_RESET_PROFILE"] = {
	text = L["Reset current profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(C.db)
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_APPLY_PROFILE"] = {
	text = L["Apply selected profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		NDuiADB["ProfileIndex"][myFullName] = G.currentProfile
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_DOWNLOAD_PROFILE"] = {
	text = L["Download selected profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local profileIndex = NDuiADB["ProfileIndex"][myFullName]
		if G.currentProfile == 1 then
			NDuiPDB[profileIndex-1] = NDuiDB
		elseif profileIndex == 1 then
			NDuiDB = NDuiPDB[G.currentProfile-1]
		else
			NDuiPDB[profileIndex-1] = NDuiPDB[G.currentProfile-1]
		end
		ReloadUI()
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_UPLOAD_PROFILE"] = {
	text = L["Upload current profile?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		if G.currentProfile == 1 then
			NDuiDB = C.db
		else
			NDuiPDB[G.currentProfile-1] = C.db
		end
	end,
	whileDead = 1,
}

StaticPopupDialogs["NDUI_DELETE_UNIT_PROFILE"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		local name, realm = strsplit("-", self.text.text_arg1)
		if NDuiADB["totalGold"][realm] and NDuiADB["totalGold"][realm][name] then
			NDuiADB["totalGold"][realm][name] = nil
		end
		NDuiADB["ProfileIndex"][self.text.text_arg1] = nil
	end,
	OnShow = function(self)
		local r, g, b
		local class = self.text.text_arg2
		if class == "NONE" then
			r, g, b = .5, .5, .5
		else
			r, g, b = B.ClassColor(class)
		end
		self.text:SetText(format(L["Delete unit profile?"], B.HexRGB(r, g, b), self.text.text_arg1))
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

function G:GetClassFromGoldInfo(name, realm)
	local class = "NONE"
	if NDuiADB["totalGold"][realm] and NDuiADB["totalGold"][realm][name] then
		class = NDuiADB["totalGold"][realm][name][2]
	end
	return class
end

function G:FindProfleUser(icon)
	icon.list = {}
	for fullName, index in pairs(NDuiADB["ProfileIndex"]) do
		if index == icon.index then
			local name, realm = strsplit("-", fullName)
			if not icon.list[realm] then icon.list[realm] = {} end
			icon.list[realm][Ambiguate(fullName, "none")] = G:GetClassFromGoldInfo(name, realm)
		end
	end
end

function G:Icon_OnEnter()
	if not next(self.list) then return end

	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["SharedCharacters"])
	GameTooltip:AddLine(" ")
	local r, g, b
	for _, value in pairs(self.list) do
		for name, class in pairs(value) do
			if class == "NONE" then
				r, g, b = .5, .5, .5
			else
				r, g, b = B.ClassColor(class)
			end
			GameTooltip:AddLine(name, r, g, b)
		end
	end
	GameTooltip:Show()
end

function G:Note_OnEscape()
	self:SetText(NDuiADB["ProfileNames"][self.index])
end

function G:Note_OnEnter()
	local text = self:GetText()
	if text == "" then
		NDuiADB["ProfileNames"][self.index] = self.__defaultText
		self:SetText(self.__defaultText)
	else
		NDuiADB["ProfileNames"][self.index] = text
	end
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
		icon.index = index
		G:FindProfleUser(icon)
		icon:SetScript("OnEnter", G.Icon_OnEnter)
		icon:SetScript("OnLeave", B.HideTooltip)
	end

	local note = B.CreateEditBox(bar, 150, 32)
	note:SetPoint("LEFT", icon, "RIGHT", 5, 0)
	note:SetMaxLetters(20)
	if index == 1 then
		note.__defaultText = L["DefaultCharacterProfile"]
	else
		note.__defaultText = L["DefaultSharedProfile"]..(index - 1)
	end
	if not NDuiADB["ProfileNames"][index] then
		NDuiADB["ProfileNames"][index] = note.__defaultText
	end
	note:SetText(NDuiADB["ProfileNames"][index])
	note.index = index
	note:HookScript("OnEnterPressed", G.Note_OnEnter)
	note:HookScript("OnEscapePressed", G.Note_OnEscape)
	note.title = L["ProfileName"]
	B.AddTooltip(note, "ANCHOR_TOP", L["ProfileNameTip"], "info")

	local reset = G:CreateProfileIcon(bar, 1, "Atlas:transmog-icon-revert", L["ResetProfile"], L["ResetProfileTip"])
	reset:SetScript("OnClick", G.Reset_OnClick)
	bar.reset = reset

	local apply = G:CreateProfileIcon(bar, 2, "Interface\\RAIDFRAME\\ReadyCheck-Ready", L["SelectProfile"], L["SelectProfileTip"])
	apply:SetScript("OnClick", G.Apply_OnClick)
	bar.apply = apply

	local download = G:CreateProfileIcon(bar, 3, "Atlas:streamcinematic-downloadicon", L["DownloadProfile"], L["DownloadProfileTip"])
	download.Icon:SetTexCoord(.25, .75, .25, .75)
	download:SetScript("OnClick", G.Download_OnClick)
	bar.download = download

	local upload = G:CreateProfileIcon(bar, 4, "Atlas:bags-icon-addslots", L["UploadProfile"], L["UploadProfileTip"])
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
			B.SetBorderColor(bar.apply.bg)
		end
	end
end

function G:Delete_OnEnter()
	local text = self:GetText()
	if not text or text == "" then return end
	local name, realm = strsplit("-", text)
	if not realm then
		realm = DB.MyRealm
		text = name.."-"..realm
		self:SetText(text)
	end

	if NDuiADB["ProfileIndex"][text] or (NDuiADB["totalGold"][realm] and NDuiADB["totalGold"][realm][name]) then
		StaticPopup_Show("NDUI_DELETE_UNIT_PROFILE", text, G:GetClassFromGoldInfo(name, realm))
	else
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Incorrect unit name"])
	end
end

function G:Delete_OnEscape()
	self:SetText("")
end

function G:CreateProfileGUI(parent)
	local reset = B.CreateButton(parent, 120, 24, L["NDui Reset"])
	reset:SetPoint("BOTTOMRIGHT", -10, 10)
	reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI")
	end)

	local restore = B.CreateButton(parent, 120, 24, L["Reset Help"])
	restore:SetPoint("BOTTOM", reset, "TOP", 0, 2)
	restore:SetScript("OnClick", function()
		StaticPopup_Show("RESET_NDUI_HELPINFO")
	end)

	local import = B.CreateButton(parent, 120, 24, L["Import"])
	import:SetPoint("BOTTOMLEFT", 10, 10)
	import:SetScript("OnClick", function()
		parent:GetParent():Hide()
		G:CreateDataFrame()
		G.ProfileDataFrame.Header:SetText(L["Import Header"])
		G.ProfileDataFrame.text:SetText(L["Import"])
		G.ProfileDataFrame.editBox:SetText("")
	end)

	local export = B.CreateButton(parent, 120, 24, L["Export"])
	export:SetPoint("LEFT", import, "RIGHT", 5, 0)
	export:SetScript("OnClick", function()
		parent:GetParent():Hide()
		G:CreateDataFrame()
		G.ProfileDataFrame.Header:SetText(L["Export Header"])
		G.ProfileDataFrame.text:SetText(OKAY)
		G:ExportGUIData()
	end)

	B.CreateFS(parent, 14, L["Profile Management"], "system", "TOPLEFT", 10, -10)
	local description = B.CreateFS(parent, 14, L["Profile Description"], nil, "TOPLEFT", 10, -35)
	description:SetPoint("TOPRIGHT", -10, -30)
	description:SetWordWrap(true)
	description:SetJustifyH("LEFT")

	local delete = B.CreateEditBox(parent, 245, 24)
	delete:SetPoint("BOTTOMLEFT", import, "TOPLEFT", 0, 2)
	delete:HookScript("OnEnterPressed", G.Delete_OnEnter)
	delete:HookScript("OnEscapePressed", G.Delete_OnEscape)
	delete.title = L["DeleteUnitProfile"]
	B.AddTooltip(delete, "ANCHOR_TOP", L["DeleteUnitProfileTip"], "info")

	G.currentProfile = NDuiADB["ProfileIndex"][DB.MyFullName]

	local numBars = 6
	local panel = B.CreateBDFrame(parent, .25)
	panel:ClearAllPoints()
	panel:SetPoint("BOTTOMLEFT", delete, "TOPLEFT", 0, 10)
	panel:SetWidth(parent:GetWidth() - 20)
	panel:SetHeight(15 + numBars*45)
	panel:SetFrameLevel(11)

	G.bars = {}
	for i = 1, numBars do
		G.bars[i] = G:CreateProfileBar(panel, i)
	end

	G:UpdateCurrentProfile()
end

-- Data transfer
local bloodlustFilter = {
	[57723] = true,
	[57724] = true,
	[80354] = true,
	[264689] = true
}

local accountStrValues = {
	["ChatFilterList"] = true,
	["ChatFilterWhiteList"] = true,
	["CustomTex"] = true,
	["IgnoredButtons"] = true,
}

local spellBooleanValues = {
	["RaidBuffsWhite"] = true,
	["RaidDebuffsBlack"] = true,
	["NameplateWhite"] = true,
	["NameplateBlack"] = true,
}

local booleanTable = {
	["CustomUnits"] = true,
	["PowerUnits"] = true,
	["DotSpells"] = true,
}

function G:ExportGUIData()
	local text = "NDuiSettings:"..DB.Version..":"..DB.MyName..":"..DB.MyClass
	for KEY, VALUE in pairs(C.db) do
		if type(VALUE) == "table" then
			for key, value in pairs(VALUE) do
				if type(value) == "table" then
					if value.r then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..v
						end
					elseif key == "ExplosiveCache" then
						text = text..";"..KEY..":"..key..":EMPTYTABLE"
					elseif KEY == "AuraWatchList" then
						if key == "Switcher" then
							for k, v in pairs(value) do
								text = text..";"..KEY..":"..key..":"..k..":"..tostring(v)
							end
						elseif key == "IgnoreSpells" then
							-- do nothing
						else
							for spellID, k in pairs(value) do
								text = text..";"..KEY..":"..key..":"..spellID
								if k[5] == nil then k[5] = false end
								for _, v in ipairs(k) do
									text = text..":"..tostring(v)
								end
							end
						end
					elseif KEY == "Mover" or KEY == "InternalCD" or KEY == "AuraWatchMover" then
						text = text..";"..KEY..":"..key
						for _, v in ipairs(value) do
							text = text..":"..tostring(v)
						end
					elseif key == "CustomItems" or key == "CustomNames" then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..v
						end
					elseif booleanTable[key] then
						text = text..";"..KEY..":"..key
						for k, v in pairs(value) do
							text = text..":"..k..":"..tostring(v)
						end
					end
				else
					if C.db[KEY][key] ~= G.DefaultSettings[KEY][key] then -- don't export default settings
						text = text..";"..KEY..":"..key..":"..tostring(value)
					end
				end
			end
		end
	end

	for KEY, VALUE in pairs(NDuiADB) do
		if spellBooleanValues[KEY] then
			text = text..";ACCOUNT:"..KEY
			for spellID, value in pairs(VALUE) do
				text = text..":"..spellID..":"..tostring(value)
			end
		elseif KEY == "RaidDebuffs" then
			for instName, value in pairs(VALUE) do
				for spellID, prio in pairs(value) do
					text = text..";ACCOUNT:"..KEY..":"..instName..":"..spellID..":"..prio
				end
			end
		elseif KEY == "CornerSpells" then
			text = text..";ACCOUNT:"..KEY
			for class, value in pairs(VALUE) do
				if class == DB.MyClass then
					text = text..":"..class
					for spellID, data in pairs(value) do
						if not bloodlustFilter[spellID] then
							local anchor, color, filter = unpack(data)
							anchor = anchor or ""
							color = color or {"", "", ""}
							text = text..":"..spellID..":"..anchor..":"..color[1]..":"..color[2]..":"..color[3]..":"..tostring(filter or false)
						end
					end
				end
			end
		elseif KEY == "ContactList" then
			text = text..";ACCOUNT:"..KEY
			for name, color in pairs(VALUE) do
				local r, g, b = strsplit(":", color)
				r = B:Round(r, 2)
				g = B:Round(g, 2)
				b = B:Round(b, 2)
				text = text..":"..name..":"..r..":"..g..":"..b
			end
		elseif KEY == "ProfileIndex" or KEY == "ProfileNames" then
			text = text..";ACCOUNT:"..KEY
			for k, v in pairs(VALUE) do
				text = text..":"..k..":"..v
			end
		elseif KEY == "ClickSets" then
			text = text..";ACCOUNT:"..KEY
			if NDuiADB[KEY][DB.MyClass] then
				text = text..":"..DB.MyClass
				for fullkey, value in pairs(NDuiADB[KEY][DB.MyClass]) do
					value = gsub(value, "%:", "`")
					value = gsub(value, ";", "}")
					text = text..":"..fullkey..":"..value
				end
			end
		elseif VALUE == true or VALUE == false or accountStrValues[KEY] then
			text = text..";ACCOUNT:"..KEY..":"..tostring(VALUE)
		end
	end

	G.ProfileDataFrame.editBox:SetText(B:Encode(text))
	G.ProfileDataFrame.editBox:HighlightText()
end

local function toBoolean(value)
	if value == "true" then
		return true
	elseif value == "false" then
		return false
	end
end

local function reloadDefaultSettings()
	for i, j in pairs(G.DefaultSettings) do
		if type(j) == "table" then
			if not C.db[i] then C.db[i] = {} end
			for k, v in pairs(j) do
				C.db[i][k] = v
			end
		else
			C.db[i] = j
		end
	end
	C.db["BFA"] = true -- don't empty data on next loading
end

local function IsOldProfileVersion(version)
	local major, minor, patch = strsplit(".", version)
	major = tonumber(major)
	minor = tonumber(minor)
	patch = tonumber(patch)
	return major < 3 and minor < 11
end

function G:ImportGUIData()
	local profile = G.ProfileDataFrame.editBox:GetText()
	if B:IsBase64(profile) then profile = B:Decode(profile) end
	local options = {strsplit(";", profile)}
	local title, version, _, class = strsplit(":", options[1])
	if title ~= "NDuiSettings" or IsOldProfileVersion(version) then
		UIErrorsFrame:AddMessage(DB.InfoColor..L["Import data error"])
		return
	end

	-- we don't export default settings, so need to reload it
	reloadDefaultSettings()

	for i = 2, #options do
		local option = options[i]
		local key, value, arg1 = strsplit(":", option)
		if arg1 == "true" or arg1 == "false" then
			if key == "ACCOUNT" then
				NDuiADB[value] = toBoolean(arg1)
			else
				C.db[key][value] = toBoolean(arg1)
			end
		elseif arg1 == "EMPTYTABLE" then
			C.db[key][value] = {}
		elseif strfind(value, "Color") and (arg1 == "r" or arg1 == "g" or arg1 == "b") then
			local colors = {select(3, strsplit(":", option))}
			if C.db[key][value] then
				for i = 1, #colors, 2 do
					C.db[key][value][colors[i]] = tonumber(colors[i+1])
				end
			end
		elseif key == "AuraWatchList" then
			if value == "Switcher" then
				local index, state = select(3, strsplit(":", option))
				C.db[key][value][tonumber(index)] = toBoolean(state)
			elseif value == "IgnoreSpells" then
				-- do nothing
			else
				local idType, spellID, unit, caster, stack, amount, timeless, combat, text, flash = select(4, strsplit(":", option))
				value = tonumber(value)
				arg1 = tonumber(arg1)
				spellID = tonumber(spellID)
				stack = tonumber(stack)
				amount = toBoolean(amount)
				timeless = toBoolean(timeless)
				combat = toBoolean(combat)
				flash = toBoolean(flash)
				if not C.db[key][value] then C.db[key][value] = {} end
				C.db[key][value][arg1] = {idType, spellID, unit, caster, stack, amount, timeless, combat, text, flash}
			end
		elseif booleanTable[value] then
			local results = {select(3, strsplit(":", option))}
			for i = 1, #results, 2 do
				C.db[key][value][tonumber(results[i]) or results[i]] = toBoolean(results[i+1])
			end
		elseif value == "CustomItems" or value == "CustomNames" then
			local results = {select(3, strsplit(":", option))}
			for i = 1, #results, 2 do
				C.db[key][value][tonumber(results[i])] = tonumber(results[i+1]) or results[i+1]
			end
		elseif key == "Mover" or key == "AuraWatchMover" then
			local relFrom, parent, relTo, x, y = select(3, strsplit(":", option))
			value = tonumber(value) or value
			x = tonumber(x)
			y = tonumber(y)
			C.db[key][value] = {relFrom, parent, relTo, x, y}
		elseif key == "InternalCD" then
			local spellID, duration, indicator, unit, itemID = select(3, strsplit(":", option))
			spellID = tonumber(spellID)
			duration = tonumber(duration)
			itemID = tonumber(itemID)
			C.db[key][spellID] = {spellID, duration, indicator, unit, itemID}
		elseif value == "InfoStrLeft" or value == "InfoStrRight" or accountStrValues[value] then
			if key == "ACCOUNT" then
				NDuiADB[value] = arg1
			else
				C.db[key][value] = arg1
			end
		elseif key == "ACCOUNT" then
			if spellBooleanValues[value] then
				local results = {select(3, strsplit(":", option))}
				for i = 1, #results, 2 do
					NDuiADB[value][tonumber(results[i])] = toBoolean(results[i+1])
				end
			elseif value == "RaidDebuffs" then
				local instName, spellID, priority = select(3, strsplit(":", option))
				if not NDuiADB[value][instName] then NDuiADB[value][instName] = {} end
				NDuiADB[value][instName][tonumber(spellID)] = tonumber(priority)
			elseif value == "CornerSpells" then
				local results = {select(3, strsplit(":", option))}
				local class = results[1]
				if class == DB.MyClass then
					for i = 2, #results, 6 do
						local spellID, anchor, r, g, b, filter = results[i], results[i+1], results[i+2], results[i+3], results[i+4], results[i+5]
						spellID = tonumber(spellID)
						r = tonumber(r)
						g = tonumber(g)
						b = tonumber(b)
						filter = toBoolean(filter)
						if not NDuiADB[value][class] then NDuiADB[value][class] = {} end
						if anchor == "" then
							NDuiADB[value][class][spellID] = {}
						else
							NDuiADB[value][class][spellID] = {anchor, {r, g, b}, filter}
						end
					end
				end
			elseif value == "ContactList" then
				local names = {select(3, strsplit(":", option))}
				for i = 1, #names, 4 do
					NDuiADB[value][names[i]] = names[i+1]..":"..names[i+2]..":"..names[i+3]
				end
			elseif value == "ProfileIndex" then
				local results = {select(3, strsplit(":", option))}
				for i = 1, #results, 2 do
					NDuiADB[value][results[i]] = tonumber(results[i+1])
				end
			elseif value == "ProfileNames" then
				local results = {select(3, strsplit(":", option))}
				for i = 1, #results, 2 do
					NDuiADB[value][tonumber(results[i])] = results[i+1]
				end
			elseif value == "ClickSets" then
				if arg1 == DB.MyClass then
					NDuiADB[value][arg1] = NDuiADB[value][arg1] or {}
					local results = {select(4, strsplit(":", option))}
					for i = 1, #results, 2 do
						results[i+1] = gsub(results[i+1], "`", ":")
						results[i+1] = gsub(results[i+1], "}", ";")
						NDuiADB[value][arg1][results[i]] = tonumber(results[i+1]) or results[i+1]
					end
				end
			end
		elseif tonumber(arg1) then
			if value == "DBMCount" or value == "StatOrder" then
				C.db[key][value] = arg1
			elseif C.db[key] then
				C.db[key][value] = tonumber(arg1)
			end
		end
	end
	ReloadUI()
end

local function updateTooltip()
	local dataFrame = G.ProfileDataFrame
	local profile = dataFrame.editBox:GetText()
	if B:IsBase64(profile) then profile = B:Decode(profile) end
	local option = strsplit(";", profile)
	local title, version, name, class = strsplit(":", option)
	if title == "NDuiSettings" then
		dataFrame.version = version
		dataFrame.name = name
		dataFrame.class = class
	else
		dataFrame.version = nil
	end
end

function G:CreateDataFrame()
	if G.ProfileDataFrame then G.ProfileDataFrame:Show() return end

	local dataFrame = CreateFrame("Frame", nil, UIParent)
	dataFrame:SetPoint("CENTER")
	dataFrame:SetSize(500, 500)
	dataFrame:SetFrameStrata("DIALOG")
	B.CreateMF(dataFrame)
	B.SetBD(dataFrame)
	dataFrame.Header = B.CreateFS(dataFrame, 16, L["Export Header"], true, "TOP", 0, -5)

	local scrollArea = CreateFrame("ScrollFrame", nil, dataFrame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 40)
	B.CreateBDFrame(scrollArea, .25)
	B.ReskinScroll(scrollArea.ScrollBar)

	local editBox = CreateFrame("EditBox", nil, dataFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(true)
	editBox:SetFont(DB.Font[1], 14, "")
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(scrollArea:GetHeight())
	editBox:SetScript("OnEscapePressed", function() dataFrame:Hide() end)
	scrollArea:SetScrollChild(editBox)
	dataFrame.editBox = editBox

	StaticPopupDialogs["NDUI_IMPORT_DATA"] = {
		text = L["Import data warning"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			G:ImportGUIData()
		end,
		whileDead = 1,
	}
	local accept = B.CreateButton(dataFrame, 100, 20, OKAY)
	accept:SetPoint("BOTTOM", 0, 10)
	accept:SetScript("OnClick", function(self)
		if self.text:GetText() ~= OKAY and dataFrame.editBox:GetText() ~= "" then
			StaticPopup_Show("NDUI_IMPORT_DATA")
		end
		dataFrame:Hide()
	end)
	accept:HookScript("OnEnter", function(self)
		if dataFrame.editBox:GetText() == "" then return end
		updateTooltip()

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
		GameTooltip:ClearLines()
		if dataFrame.version then
			GameTooltip:AddLine(L["Data Info"])
			GameTooltip:AddDoubleLine(L["Version"], dataFrame.version, .6,.8,1, 1,1,1)
			GameTooltip:AddDoubleLine(L["Character"], dataFrame.name, .6,.8,1, B.ClassColor(dataFrame.class))
		else
			GameTooltip:AddLine(L["Data Exception"], 1,0,0)
		end
		GameTooltip:Show()
	end)
	accept:HookScript("OnLeave", B.HideTooltip)
	dataFrame.text = accept.text

	G.ProfileDataFrame = dataFrame
end