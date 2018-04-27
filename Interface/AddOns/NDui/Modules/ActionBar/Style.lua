local B, C, L, DB = unpack(select(2, ...))
local Bar = NDui:GetModule("Actionbar")
local normalColor, equipColor = {.3, .3, .3}, {.1, .5, .1}

--reskin function
local function applyBackground(bu)
	if not bu or (bu and bu.bg) then return end

	bu.bg = B.CreateBG(bu, 2)
	B.CreateBD(bu.bg)
	B.CreateTex(bu.bg)
	if NDuiDB["Actionbar"]["Classcolor"] then
		bu.bg:SetBackdropColor(DB.cc.r, DB.cc.g, DB.cc.b, .25)
	else
		bu.bg:SetBackdropColor(.2, .2, .2, .25)
	end
end

--update hotkey func
local replaces = {
	{"(Mouse Button )", "M"},
	{"(鼠标按键)", "M"},
	{"(滑鼠按鍵)", "M"},
	{"(a%-)", "a"},
	{"(c%-)", "c"},
	{"(s%-)", "s"},
	{KEY_BUTTON3, "M3"},
	{KEY_MOUSEWHEELUP, "MU"},
	{KEY_MOUSEWHEELDOWN, "MD"},
	{KEY_SPACE, "Sp"},
	{CAPSLOCK_KEY_TEXT, "CL"},
}

local function updateHotkey(self)
	local ho = _G[self:GetName().."HotKey"]
	if ho and ho:IsShown() and not NDuiDB["Actionbar"]["Hotkeys"] then
		ho:Hide()
		return
	end

	local text = ho:GetText()
	if not text then return end

	for _, value in pairs(replaces) do
		text = gsub(text, value[1], value[2])
	end

	if ho:GetText() == RANGE_INDICATOR then
		ho:SetText("")
	else
		ho:SetText(text)
	end
end
NDui.UpdateHotkey = updateHotkey

--style extraactionbutton
local function styleExtraActionButton(bu)
	if not bu or (bu and bu.styled) then return end
	local name = bu:GetName()
	local ho = _G[name.."HotKey"]
	--remove the style background theme
	bu.style:SetTexture(nil)
	hooksecurefunc(bu.style, "SetTexture", function(self, texture)
		if texture then
			self:SetTexture(nil)
		end
	end)
	--icon
	bu.icon:SetTexCoord(unpack(DB.TexCoord))
	bu.icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	bu.icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--cooldown
	bu.cooldown:SetAllPoints(bu.icon)
	--hotkey
	ho:SetFont(unpack(DB.Font))
	ho:ClearAllPoints()
	ho:SetPoint("TOPRIGHT", bu, 1, 0)
	ho:SetPoint("TOPLEFT", bu, -1, 0)
	updateHotkey(bu)
	--add button normaltexture
	bu:SetNormalTexture(DB.textures.normal)
	bu:SetPushedTexture(DB.textures.pushed)
	bu:SetCheckedTexture(DB.textures.checked)
	bu:SetHighlightTexture(nil)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(bu.icon)
	local nt = bu:GetNormalTexture()
	nt:SetVertexColor(unpack(normalColor))
	nt:SetAllPoints(bu)
	nt:SetTexCoord(unpack(DB.TexCoord))
	--apply background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

--initial style func
local function styleActionButton(bu)
	if not bu or (bu and bu.styled) then return end
	local action = bu.action
	local name = bu:GetName()
	local ic = _G[name.."Icon"]
	local co = _G[name.."Count"]
	local bo = _G[name.."Border"]
	local ho = _G[name.."HotKey"]
	local cd = _G[name.."Cooldown"]
	local na = _G[name.."Name"]
	local fl = _G[name.."Flash"]
	local nt = _G[name.."NormalTexture"]
	local fbg = _G[name.."FloatingBG"]
	local fob = _G[name.."FlyoutBorder"]
	local fobs = _G[name.."FlyoutBorderShadow"]
	if fbg then fbg:Hide() end  --floating background
	--flyout border stuff
	if fob then fob:SetTexture(nil) end
	if fobs then fobs:SetTexture(nil) end
	bo:SetTexture(nil) --hide the border (plain ugly, sry blizz)
	--new action glow
	local nat = bu.NewActionTexture
	if nat then nat:SetTexture(nil) end
	--hotkey
	ho:SetFont(unpack(DB.Font))
	ho:ClearAllPoints()
	ho:SetPoint("TOPRIGHT", bu, 1, 0)
	ho:SetPoint("TOPLEFT", bu, -1, 0)
	updateHotkey(bu)
	--macro name
	na:SetFont(unpack(DB.Font))
	na:ClearAllPoints()
	na:SetPoint("BOTTOMLEFT", bu, 0, 0)
	na:SetPoint("BOTTOMRIGHT", bu, 0, 0)
	if not NDuiDB["Actionbar"]["Macro"] then
		na:Hide()
	end
	--item stack count
	co:SetFont(unpack(DB.Font))
	co:ClearAllPoints()
	co:SetPoint("BOTTOMRIGHT", bu, 2, 0)
	if not NDuiDB["Actionbar"]["Count"] then
		co:Hide()
	end
	--applying the textures
	fl:SetTexture(DB.textures.flash)
	bu:SetPushedTexture(DB.textures.pushed)
	bu:SetCheckedTexture(DB.textures.checked)
	bu:SetNormalTexture(DB.textures.normal)
	bu:SetHighlightTexture(nil)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(ic)
	if not nt then
		--fix the non existent texture problem (no clue what is causing this)
		nt = bu:GetNormalTexture()
	end
	--cut the default border of the icons and make them shiny
	ic:SetTexCoord(unpack(DB.TexCoord))
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--adjust the cooldown frame
	cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--apply the normaltexture
	if action and IsEquippedAction(action) then
		bu:SetNormalTexture(DB.textures.equipped)
		nt:SetVertexColor(unpack(equipColor))
	else
		bu:SetNormalTexture(DB.textures.normal)
		nt:SetVertexColor(unpack(normalColor))
	end
	--make the normaltexture match the buttonsize
	nt:SetAllPoints(bu)
	nt:SetTexCoord(unpack(DB.TexCoord))
	--hook to prevent Blizzard from reseting our colors
	hooksecurefunc(nt, "SetVertexColor", function(nt, r, g, b)
		local bu = nt:GetParent()
		local action = bu.action
		--print("bu"..bu:GetName().."R"..r.."G"..g.."B"..b)
		if r==1 and g==1 and b==1 and action and IsEquippedAction(action) then
			if equipColor[1] == 1 and equipColor[2] == 1 and equipColor[3] == 1 then
				nt:SetVertexColor(.999, .999, .999)
			else
				nt:SetVertexColor(unpack(equipColor))
			end
		elseif r==.5 and g==.5 and b==1 then
			--blizzard oom color
			if normalColor[1] == .5 and normalColor[2] == .5 and normalColor[3] == 1 then
				nt:SetVertexColor(.499, .499, .999)
			else
				nt:SetVertexColor(unpack(normalColor))
			end
		elseif r==1 and g==1 and b==1 then
			if normalColor[1] == 1 and normalColor[2] == 1 and normalColor[3] == 1 then
				nt:SetVertexColor(.999, .999, .999)
			else
				nt:SetVertexColor(unpack(normalColor))
			end
		end
	end)
	--shadows+background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

local function styleLeaveButton(bu)
	if not bu or (bu and bu.styled) then return end
	--shadows+background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

--style pet buttons
local function stylePetButton(bu)
	if not bu or (bu and bu.styled) then return end
	local name = bu:GetName()
	local ic = _G[name.."Icon"]
	local fl = _G[name.."Flash"]
	local nt = _G[name.."NormalTexture2"]
	nt:SetAllPoints(bu)
	nt:SetTexCoord(unpack(DB.TexCoord))
	--applying color
	nt:SetVertexColor(unpack(normalColor))
	--setting the textures
	fl:SetTexture(DB.textures.flash)
	bu:SetPushedTexture(DB.textures.pushed)
	bu:SetCheckedTexture(DB.textures.checked)
	bu:SetNormalTexture(DB.textures.normal)
	bu:SetHighlightTexture(nil)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(ic)
	hooksecurefunc(bu, "SetNormalTexture", function(self, texture)
		--make sure the normaltexture stays the way we want it
		if texture and texture ~= DB.textures.normal then
			self:SetNormalTexture(DB.textures.normal)
		end
	end)
	--cut the default border of the icons and make them shiny
	ic:SetTexCoord(unpack(DB.TexCoord))
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--shadows+background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

--style stance buttons
local function styleStanceButton(bu)
	if not bu or (bu and bu.styled) then return end
	local name = bu:GetName()
	local ic  = _G[name.."Icon"]
	local fl  = _G[name.."Flash"]
	local nt  = _G[name.."NormalTexture2"]
	nt:SetAllPoints(bu)
	nt:SetTexCoord(unpack(DB.TexCoord))
	--applying color
	nt:SetVertexColor(unpack(normalColor))
	--setting the textures
	fl:SetTexture(DB.textures.flash)
	bu:SetPushedTexture(DB.textures.pushed)
	bu:SetCheckedTexture(DB.textures.checked)
	bu:SetNormalTexture(DB.textures.normal)
	bu:SetHighlightTexture(nil)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(ic)
	--cut the default border of the icons and make them shiny
	ic:SetTexCoord(unpack(DB.TexCoord))
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--shadows+background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

--style possess buttons
local function stylePossessButton(bu)
	if not bu or (bu and bu.styled) then return end
	local name = bu:GetName()
	local ic  = _G[name.."Icon"]
	local fl  = _G[name.."Flash"]
	local nt  = _G[name.."NormalTexture"]
	nt:SetAllPoints(bu)
	nt:SetTexCoord(unpack(DB.TexCoord))
	--applying color
	nt:SetVertexColor(unpack(normalColor))
	--setting the textures
	fl:SetTexture(DB.textures.flash)
	bu:SetPushedTexture(DB.textures.pushed)
	bu:SetCheckedTexture(DB.textures.checked)
	bu:SetNormalTexture(DB.textures.normal)
	bu:SetHighlightTexture(nil)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetColorTexture(1, 1, 1, .3)
	bu.HL:SetAllPoints(ic)
	--cut the default border of the icons and make them shiny
	ic:SetTexCoord(unpack(DB.TexCoord))
	ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
	ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
	--shadows+background
	if not bu.bg then applyBackground(bu) end
	bu.styled = true
end

-- Init
function Bar:ReskinBars()
	--style the actionbar buttons
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		styleActionButton(_G["ActionButton"..i])
		styleActionButton(_G["MultiBarBottomLeftButton"..i])
		styleActionButton(_G["MultiBarBottomRightButton"..i])
		styleActionButton(_G["MultiBarRightButton"..i])
		styleActionButton(_G["MultiBarLeftButton"..i])
	end
	for i = 1, 6 do
		styleActionButton(_G["OverrideActionBarButton"..i])
	end
	--style leave button
	styleLeaveButton(OverrideActionBarLeaveFrameLeaveButton)
	styleLeaveButton(NDui_LeaveVehicleButton)
	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		stylePetButton(_G["PetActionButton"..i])
	end
	--stancebar buttons
	for i = 1, NUM_STANCE_SLOTS do
		styleStanceButton(_G["StanceButton"..i])
	end
	--possess buttons
	for i = 1, NUM_POSSESS_SLOTS do
		stylePossessButton(_G["PossessButton"..i])
	end
	--extraactionbutton1
	styleExtraActionButton(ExtraActionButton1)
	--spell flyout
	SpellFlyoutBackgroundEnd:SetTexture(nil)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	local function checkForFlyoutButtons()
		local NUM_FLYOUT_BUTTONS = 13
		for i = 1, NUM_FLYOUT_BUTTONS do
			styleActionButton(_G["SpellFlyoutButton"..i])
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	--hide the hotkeys if needed
	hooksecurefunc("ActionButton_UpdateHotkeys", updateHotkey)
end