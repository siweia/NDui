local _, ns = ...
local B, C, L, DB = unpack(ns)
local oUF = ns.oUF
local A = B:RegisterModule("Auras")

local _G = getfenv(0)
local floor, ipairs = math.floor, ipairs
local CreateFrame = CreateFrame
local GetInventoryItemQuality = GetInventoryItemQuality
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local ShouldAurasBeSecret = C_Secrets.ShouldAurasBeSecret
local CooldownFormatter = B:GetModule("Cooldown"):GetNumberFormatter()

local DURATION_HEIGHT = 12
local CANCEL_AURA_BUTTONS = "RightButtonUp RightButtonDown"
local ITEM_ENCHANTMENT_SLOTS = {
	INVSLOT_MAINHAND,
	INVSLOT_OFFHAND,
	INVSLOT_RANGED,
}

local COUNT_FORMATTER = C_StringUtil.CreateNumericRuleFormatter()
COUNT_FORMATTER:SetBreakpoints({
	{threshold = 0, format = ""},
	{threshold = 2, format = "%d", step = 1, rounding = Enum.NumericRuleFormatRounding.Down},
	{threshold = 1000, format = ""},
})

local ROUNDING_NEAREST = Enum.NumericRuleFormatRounding.Nearest
local COLOR_RED = CreateColor(1, 0, 0, 1)
local COLOR_YELLOW = CreateColor(1, 1, 0, 1)
local DEBUFF_BORDER_COLORS = {None = COLOR_RED}

local ITEM_DURATION_FORMATTER = C_StringUtil.CreateNumericRuleFormatter()
ITEM_DURATION_FORMATTER:SetBreakpoints({
	{
		threshold = 0,
		format = COLOR_RED:WrapTextInColorCode("%.1f"),
		components = {{step = .1, rounding = ROUNDING_NEAREST}},
	},
	{
		threshold = 5,
		format = COLOR_YELLOW:WrapTextInColorCode("%.1f"),
		components = {{step = .1, rounding = ROUNDING_NEAREST}},
	},
	{
		threshold = 10,
		format = "%d"..DB.MyColor.."s",
		components = {{div = 1, step = 1, rounding = ROUNDING_NEAREST}},
	},
	{
		threshold = 60,
		format = "%d:%02d",
		components = {{div = 60}, {mod = 60}},
	},
	{
		threshold = 600,
		format = "%d"..DB.MyColor.."m",
		components = {{div = 60, step = 1, rounding = ROUNDING_NEAREST}},
	},
	{
		threshold = 7200,
		format = "%d"..DB.MyColor.."h",
		components = {{div = 3600, step = 1, rounding = ROUNDING_NEAREST}},
	},
	{
		threshold = 86400,
		format = "%d"..DB.MyColor.."d",
		components = {{div = 86400, step = 1, rounding = ROUNDING_NEAREST}},
	},
})

local ITEM_DURATION_BINDING = C_DurationUtil.CreateDurationTextBinding()
ITEM_DURATION_BINDING:SetFormatter(ITEM_DURATION_FORMATTER)
ITEM_DURATION_BINDING:SetExpiredText("")
ITEM_DURATION_BINDING:SetZeroDurationText("")

local function HideBlizzardDebuffVisuals(frame)
	if not frame then return end

	frame:SetAlpha(0)
	frame:EnableMouse(false)

	if frame.AuraContainer then
		frame.AuraContainer:Hide()
	end

	for _, anchor in ipairs(frame.PrivateAuraAnchors or {}) do
		anchor:Hide()
	end

	-- DebuffFrame must keep running so it can update DeadlyDebuffFrame.
	frame:Show()
end

local function HideBlizzardAuraFrames()
	if _G.BuffFrame then
		B.HideObject(_G.BuffFrame)
		_G.BuffFrame.numHideableBuffs = 0
	end

	HideBlizzardDebuffVisuals(_G.DebuffFrame)
end

function A:HideBlizBuff()
	if not C.db["Auras"]["BuffFrame"] and not C.db["Auras"]["HideBlizBuff"] then return end

	HideBlizzardAuraFrames()
	if not A.blizzardHideRegistered then
		B:RegisterEvent("PLAYER_ENTERING_WORLD", HideBlizzardAuraFrames)
		A.blizzardHideRegistered = true
	end
end

local function GetMaxFrameCount(cfg)
	return cfg.wrapAfter * cfg.maxWraps
end

local function GetRowWidth(cfg)
	return cfg.size * cfg.wrapAfter + C.margin * (cfg.wrapAfter - 1)
end

local function GetHolderWidth(cfg)
	return (cfg.size + C.margin) * cfg.wrapAfter
end

local function GetHolderHeight(cfg)
	return (cfg.size + cfg.offset) * cfg.maxWraps
end

local function GetLayoutOptions(cfg)
	return {
		elementSpacing = C.margin,
		lineSpacing = 0,
		groupSpacing = 0,
		groupLineSpacing = 0,
		elementWidth = cfg.size,
		elementHeight = cfg.size + cfg.offset,
	}
end

local function GetAnchorOptions(cfg)
	if cfg.reverseGrow then
		return "TOPLEFT", 1
	end

	return "TOPRIGHT", -1
end

local function UpdateButtonAppearance(button, cfg)
	button:SetSize(cfg.size, cfg.size)

	local fontSize = floor(cfg.size / 30 * 12 + .5)
	if button.Count then
		B.SetFontSize(button.Count, fontSize)
	end
	if button.Time then
		B.SetFontSize(button.Time, fontSize)
	end
	if button.CooldownText then
		B.SetFontSize(button.CooldownText, fontSize)
	end
	if button.Cooldown then
		button.Cooldown:SetDrawSwipe(C.db["Auras"]["CDAnimation"])
	end
end

local function CreateDispelBorder(button)
	local thickness = C.mult * 2
	local border = CreateFrame("Frame", nil, button)
	border:SetAllPoints()
	border:SetFrameLevel(button.Cooldown:GetFrameLevel())
	local textures = {}

	local top = border:CreateTexture(nil, "OVERLAY", nil, 7)
	top:SetColorTexture(1, 1, 1)
	top:SetPoint("TOPLEFT", button)
	top:SetPoint("TOPRIGHT", button)
	top:SetHeight(thickness)
	textures[1] = top

	local bottom = border:CreateTexture(nil, "OVERLAY", nil, 7)
	bottom:SetColorTexture(1, 1, 1)
	bottom:SetPoint("BOTTOMLEFT", button)
	bottom:SetPoint("BOTTOMRIGHT", button)
	bottom:SetHeight(thickness)
	textures[2] = bottom

	local left = border:CreateTexture(nil, "OVERLAY", nil, 7)
	left:SetColorTexture(1, 1, 1)
	left:SetPoint("TOPLEFT", button)
	left:SetPoint("BOTTOMLEFT", button)
	left:SetWidth(thickness)
	textures[3] = left

	local right = border:CreateTexture(nil, "OVERLAY", nil, 7)
	right:SetColorTexture(1, 1, 1)
	right:SetPoint("TOPRIGHT", button)
	right:SetPoint("BOTTOMRIGHT", button)
	right:SetWidth(thickness)
	textures[4] = right

	local options = {
		showWhenHarmful = true,
		showWithoutDispelType = true,
		style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
		customDispelColorMap = DEBUFF_BORDER_COLORS,
	}
	for _, texture in ipairs(textures) do
		button:AddDispelTypeTexture(texture, options)
	end
end

local function StyleAuraButton(element, button, showDebuffTypeBorder)
	button.Icon:SetTexCoord(unpack(DB.TexCoord))

	local backdrop = B.CreateBDFrame(button, .25)
	backdrop:ClearAllPoints()
	backdrop:SetAllPoints(button)
	backdrop:SetBackdropBorderColor(0, 0, 0)
	button.__nduiBackdrop = backdrop
	B.CreateSD(button)

	if showDebuffTypeBorder then
		CreateDispelBorder(button)
	end

	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetPoint("TOPRIGHT", button, -1, -3)
	end

	if button.Time then
		button.Time:ClearAllPoints()
		button.Time:SetPoint("TOP", button, "BOTTOM", 1, 2)
	end

	if button.CooldownText then
		button.CooldownText:ClearAllPoints()
		button.CooldownText:SetPoint("TOP", button, "BOTTOM", 1, 2)
	end

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(button.Icon)
	highlight:SetColorTexture(1, 1, 1, .25)
	button.Highlight = highlight

	UpdateButtonAppearance(button, element.__nduiConfig)
end

local function InitializeAuraButton(element, options, button)
	button:EnableMouse(true)
	button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", -5, -5)
	button:SetHideTooltipInCombat(false)

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetInside()
	button.Icon = icon
	button:SetIcon(icon)

	local cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	cooldown:SetAllPoints()
	cooldown:SetReverse(true)
	cooldown:SetEdgeTexture(DB.bgTex)
	cooldown:SetDrawBling(false)
	cooldown:SetCountdownFormatter(CooldownFormatter)
	button.Cooldown = cooldown
	button:SetDurationCooldown(cooldown)
	button.CooldownText = cooldown:GetCountdownFontString()

	local textFrame = CreateFrame("Frame", nil, button)
	textFrame:SetAllPoints()
	textFrame:SetFrameLevel(cooldown:GetFrameLevel() + 1)

	local count = textFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	button.Count = count
	button:SetApplicationCount(count, {formatter = COUNT_FORMATTER})

	if options.cancelButton then
		button:SetCancelAuraButtons(options.cancelButton)
	end

	StyleAuraButton(element, button, options.showDebuffTypeBorder)
end

local function UpdateItemEnchantmentBorder(button, inventorySlot)
	local quality = GetInventoryItemQuality("player", inventorySlot)
	local color = DB.QualityColors[quality or 1] or DB.QualityColors[1]
	button.__nduiBackdrop:SetBackdropBorderColor(color.r, color.g, color.b)
end

local function InitializeItemEnchantmentButton(container, inventorySlot, button)
	button:EnableMouse(true)
	button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", -5, -5)
	button:SetHideTooltipInCombat(false)

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetInside()
	button.Icon = icon
	button:SetIcon(icon)

	local time = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	button.Time = time
	button:SetDurationText(time, {binding = ITEM_DURATION_BINDING})
	button:SetCancelAuraButtons(CANCEL_AURA_BUTTONS)

	StyleAuraButton(container, button)
	container.__itemButtons[inventorySlot] = button
	UpdateItemEnchantmentBorder(button, inventorySlot)
end

local function CreateItemEnchantmentOptions(container, inventorySlot)
	return {
		hidePermanent = true,
		initializeFrame = function(button)
			InitializeItemEnchantmentButton(container, inventorySlot, button)
		end,
	}
end

local function CreateHolder(name, cfg, visibility)
	local holder = CreateFrame("Frame", name, UIParent)
	holder:SetClampedToScreen(true)
	holder:SetSize(GetHolderWidth(cfg), GetHolderHeight(cfg))
	RegisterStateDriver(holder, "visibility", visibility or "[petbattle] hide; show")
	return holder
end

local function CreateOverlayHolder(name, parent)
	local holder = CreateFrame("Frame", name, parent)
	holder:SetAllPoints(parent)
	return holder
end

function A:CreateAuraHeader(filter, name, visibility)
	local cfg = filter == "HELPFUL" and A.settings.Buffs or A.settings.Debuffs
	local holderName = name or (filter == "HELPFUL" and "NDuiPlayerBuffs" or "NDuiPlayerDebuffs")
	return CreateHolder(holderName, cfg, visibility)
end

local function CreateAuraContainer(owner, holder, cfg)
	local anchor, growthX = GetAnchorOptions(cfg)
	local container = owner:CreateAuras({
		layout = AnchorUtil.FlowLayoutAxis.Horizontal,
		layoutLimit = GetRowWidth(cfg),
		initialAnchor = anchor,
		growthX = growthX < 0 and "LEFT" or "RIGHT",
		growthY = "DOWN",
	})
	container:SetParent(holder)
	container:ClearAllPoints()
	container:SetPoint(anchor, holder, anchor)
	container.__nduiConfig = cfg
	container.__itemButtons = {}
	container.CreateButton = InitializeAuraButton
	return container
end

local function AddItemEnchantments(container)
	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.MainHand, CreateItemEnchantmentOptions(container, INVSLOT_MAINHAND))
	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.OffHand, CreateItemEnchantmentOptions(container, INVSLOT_OFFHAND))
	container:AddItemEnchantment(AuraContainerItemEnchantmentSlot.Ranged, CreateItemEnchantmentOptions(container, INVSLOT_RANGED))
	container:SetItemEnchantmentSortMethod(AuraContainerItemEnchantmentSortMethod.Slot, AuraContainerSortDirection.Normal)

	local layout = GetLayoutOptions(container.__nduiConfig)
	layout.placement = CustomAuraContainerItemEnchantmentPlacement.BeforeAuraGroups
	container:SetItemEnchantmentLayout(layout)
end

local function AddAuraGroup(container, filter, showDebuffTypeBorder)
	local cfg = container.__nduiConfig
	local groupKey = container:AddGroup(filter, {
		maxFrameCount = GetMaxFrameCount(cfg),
		cancelButton = filter == "HELPFUL" and CANCEL_AURA_BUTTONS or nil,
		showDebuffTypeBorder = showDebuffTypeBorder,
		sortMethod = AuraContainerSortMethod.Default,
		sortDirection = AuraContainerSortDirection.Normal,
		layout = GetLayoutOptions(cfg),
	})
	container.__groupKey = groupKey
	return groupKey
end

local function GetActiveItemEnchantmentCount()
	local activeCount = 0
	for _, slot in ipairs(ITEM_ENCHANTMENT_SLOTS) do
		local enchantmentInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo(slot)
		if enchantmentInfo and enchantmentInfo.hasExpirationTime then
			activeCount = activeCount + 1
		end
	end
	return activeCount
end

function A:UpdateBuffAuraLimit()
	local activeCount = GetActiveItemEnchantmentCount()
	for _, container in ipairs({A.BuffContainer, A.VehicleBuffContainer}) do
		if container and container.__groupKey then
			local maxFrameCount = GetMaxFrameCount(container.__nduiConfig) - activeCount
			container:SetAuraGroupMaxFrameCount(container.__groupKey, maxFrameCount)
		end
	end
end

function A:UpdateOptions()
	if not A.settings then
		A.settings = {
			Buffs = {offset = DURATION_HEIGHT, maxWraps = 3},
			Debuffs = {offset = DURATION_HEIGHT, maxWraps = 1},
		}
	end

	A.settings.Buffs.size = C.db["Auras"]["BuffSize"]
	A.settings.Buffs.wrapAfter = C.db["Auras"]["BuffsPerRow"]
	A.settings.Buffs.reverseGrow = C.db["Auras"]["ReverseBuff"]
	A.settings.Debuffs.size = C.db["Auras"]["DebuffSize"]
	A.settings.Debuffs.wrapAfter = C.db["Auras"]["DebuffsPerRow"]
	A.settings.Debuffs.reverseGrow = C.db["Auras"]["ReverseDebuff"]
end

local itemBorderUpdatePending
local function UpdateItemEnchantmentBorders()
	if InCombatLockdown() or ShouldAurasBeSecret() then
		itemBorderUpdatePending = true
		return
	end
	itemBorderUpdatePending = nil

	for _, container in ipairs({A.BuffContainer, A.VehicleBuffContainer}) do
		if container then
			for inventorySlot, button in pairs(container.__itemButtons) do
				UpdateItemEnchantmentBorder(button, inventorySlot)
			end
		end
	end
end

local function OnAuraEvent(_, event)
	A:UpdateBuffAuraLimit()

	if itemBorderUpdatePending or event == "PLAYER_ENTERING_WORLD" or event == "WEAPON_SLOT_CHANGED" then
		UpdateItemEnchantmentBorders()
	end
end

local activeBuffUnit
local function UpdateBuffHolderVisibility(owner)
	local unit = owner.__unit
	if unit == activeBuffUnit then return end

	activeBuffUnit = unit
	local isVehicle = unit == "vehicle"
	A.PlayerBuffFrame:SetShown(not isVehicle)
	A.VehicleBuffFrame:SetShown(isVehicle)
end

function A:CreatePlayerAuraFrames(owner)
	if A.auraContainersBuilt then return end
	A.auraContainersBuilt = true

	A.BuffContainer = CreateAuraContainer(owner, A.PlayerBuffFrame, A.settings.Buffs)
	AddItemEnchantments(A.BuffContainer)
	AddAuraGroup(A.BuffContainer, "HELPFUL")

	A.VehicleBuffContainer = CreateAuraContainer(owner, A.VehicleBuffFrame, A.settings.Buffs)
	AddItemEnchantments(A.VehicleBuffContainer)
	AddAuraGroup(A.VehicleBuffContainer, "HELPFUL")

	A.DebuffContainer = CreateAuraContainer(owner, A.DebuffFrame, A.settings.Debuffs)
	AddAuraGroup(A.DebuffContainer, "HARMFUL", true)

	A:UpdateBuffAuraLimit()

	local previousPostUpdate = owner.PostUpdate
	owner.PostUpdate = function(self, event)
		if previousPostUpdate then
			previousPostUpdate(self, event)
		end
		UpdateBuffHolderVisibility(self)
	end
	UpdateBuffHolderVisibility(owner)

	local controller = CreateFrame("Frame")
	controller:RegisterEvent("PLAYER_ENTERING_WORLD")
	controller:RegisterEvent("PLAYER_REGEN_ENABLED")
	controller:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	controller:RegisterEvent("ENCOUNTER_END")
	controller:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	controller:RegisterEvent("PVP_MATCH_COMPLETE")
	controller:RegisterEvent("WEAPON_ENCHANT_CHANGED")
	controller:RegisterEvent("WEAPON_SLOT_CHANGED")
	controller:SetScript("OnEvent", OnAuraEvent)
	A.controller = controller
end

local function CreateAuraOwner(self)
	self:SetSize(1, 1)
	self:SetPoint("TOPLEFT", UIParent)
	self:EnableMouse(false)
	A:CreatePlayerAuraFrames(self)
end

function A:BuildBuffFrame()
	if A.auraFramesBuilt or not C.db["Auras"]["BuffFrame"] then return end
	A.auraFramesBuilt = true
	A:UpdateOptions()

	A.BuffFrame = A:CreateAuraHeader("HELPFUL", "NDuiPlayerBuffs")
	A.BuffFrame.mover = B.Mover(A.BuffFrame, "Buffs", "BuffAnchor", C.Auras.BuffPos)
	A.BuffFrame:ClearAllPoints()
	A.BuffFrame:SetPoint("TOPRIGHT", A.BuffFrame.mover)

	A.PlayerBuffFrame = CreateOverlayHolder("NDuiPlayerBuffHolder", A.BuffFrame)
	A.VehicleBuffFrame = CreateOverlayHolder("NDuiVehicleBuffHolder", A.BuffFrame)

	A.DebuffFrame = A:CreateAuraHeader("HARMFUL", "NDuiPlayerDebuffs")
	A.DebuffFrame.mover = B.Mover(A.DebuffFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", A.BuffFrame.mover, "BOTTOMRIGHT", 0, -12})
	A.DebuffFrame:ClearAllPoints()
	A.DebuffFrame:SetPoint("TOPRIGHT", A.DebuffFrame.mover)

	local activeStyle = oUF:GetActiveStyle()
	oUF:RegisterStyle("NDuiPlayerAuras", CreateAuraOwner)
	oUF:SetActiveStyle("NDuiPlayerAuras")
	A.AuraOwner = oUF:Spawn("player", "oUF_NDuiPlayerAuras", true)
	if activeStyle then
		oUF:SetActiveStyle(activeStyle)
	end
end

function A:OnLogin()
	A:HideBlizBuff()
	A:BuildBuffFrame()
	A:Totems()
	A:InitReminder()
end
