local _, ns = ...
local oUF = ns.oUF
local argcheck = oUF.Private.argcheck

local STATE, POOLS = {}, {}
local elementMixin = {}

local function CreateButton(element, options, button)
	local size = options.size or element.size or 16
	local width = options.width or element.width or size
	local height = options.height or element.height or size
	button:SetSize(width, height)
	button:EnableMouse(not (options.disableMouse or element.disableMouse))
	button:SetTooltipAnchorPoint(options.tooltipAnchor or element.tooltipAnchor or 'ANCHOR_BOTTOMLEFT', options.tooltipOffsetX or element.tooltipOffsetX or 0, options.tooltipOffsetY or element.tooltipOffsetY or 0)
	button:SetHideTooltipInCombat(options.tooltipHideInCombat or element.tooltipHideInCombat)

	if not (options.disableCooldown or element.disableCooldown) then
		local cooldown = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
		cooldown:SetAllPoints()
		button.Cooldown = cooldown
		button:SetDurationCooldown(cooldown)
	end

	local icon = button:CreateTexture(nil, 'BORDER')
	icon:SetAllPoints()
	button.Icon = icon
	button:SetIcon(icon)

	local textParent = button
	if options.showCount or element.showCount or options.showDuration or element.showDuration then
		if button.Cooldown and not (options.disableCooldown or element.disableCooldown) then
			textParent = CreateFrame('Frame', nil, button)
			textParent:SetAllPoints()
			textParent:SetFrameLevel(button.Cooldown:GetFrameLevel() + 1)
		end
	end

	if options.showCount or element.showCount then
		local count = textParent:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
		count:SetPoint('BOTTOMRIGHT', -1, 0)
		button.Count = count
		button:SetApplicationCount(count, {formatter = options.countFormatter or element.countFormatter})
	end

	if (options.showBuffBorder or element.showBuffBorder) or (options.showDebuffBorder or element.showDebuffBorder) then
		local border = button:CreateTexture(nil, 'OVERLAY')
		border:SetAllPoints()
		button.Border = border
		button:AddDispelTypeTexture(border, {
			style = options.dispelBorderStyle or element.dispelBorderStyle or Enum.CustomAuraButtonDispelTypeTextureStyle.Border,
			showWhenHarmful = options.showDebuffBorder or element.showDebuffBorder,
			showWhenHelpful = options.showBuffBorder or element.showBuffBorder,
			customDispelColorMap = element.__owner and element.__owner.colors.dispel or oUF.colors.dispel,
		})
	end

	if options.showStealableBorder or element.showStealableBorder then
		local stealable = button:CreateTexture(nil, 'OVERLAY')
		stealable:SetPoint('TOPLEFT', -3, 3)
		stealable:SetPoint('BOTTOMRIGHT', 3, -3)
		stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
		stealable:SetBlendMode('ADD')
		button.Stealable = stealable
		button:AddDispelTypeTexture(stealable, {
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			showWhenHelpful = true,
			showWithoutDispelType = true,
			stealableFilter = options.stealableBorderFilter or element.stealableBorderFilter or Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable,
		})
	end

	if options.showDuration or element.showDuration then
		local time = textParent:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
		time:SetPoint('TOPLEFT', 1, 0)
		button.Time = time
		button:SetDurationText(time, {binding = options.durationBinding or element.durationBinding, textFormatter = options.durationFormatter or element.durationFormatter, textFormat = options.durationFormat or element.durationFormat, textColor = options.durationColors or element.durationColors})
	end
	if options.cancelButton or element.cancelButton then button:SetCancelAuraButtons(options.cancelButton or element.cancelButton) end
	if element.PostCreateButton then element:PostCreateButton(button, options) end
end

function elementMixin:AddGroup(filter, options)
	argcheck(filter, 2, 'string')
	options = options or {}
	options.maxFrameCount = options.maxFrameCount or self.maxFrameCount
	local layout = options.layout or {}
	layout.elementSpacing = layout.elementSpacing or self.elementSpacing
	layout.lineSpacing = layout.lineSpacing or self.lineSpacing
	layout.groupSpacing = layout.groupSpacing or self.groupSpacing
	layout.groupLineSpacing = layout.groupLineSpacing or self.groupLineSpacing
	layout.forceNewLine = layout.forceNewLine or self.forceNewLine
	options.layout = layout
	options.sortMethod = options.sortMethod or self.sortMethod or AuraContainerSortMethod.ExpirationOnly
	options.sortDirection = options.sortDirection or self.sortDirection or AuraContainerSortDirection.Normal
	self.__state.groupIndex = self.__state.groupIndex + 1
	local key = 'Group' .. self.__state.groupIndex
	options.initializeFrame = GenerateClosure(options.CreateButton or self.CreateButton or CreateButton, self, options)
	self:AddAuraGroup(key, filter, options)
	return key
end

function elementMixin:AddSlot(filter, options)
	argcheck(filter, 2, 'string')
	options = options or {}
	self.__state.slotIndex = self.__state.slotIndex + 1
	local key = 'Slot' .. self.__state.slotIndex
	options.initializeFrame = GenerateClosure(options.CreateButton or self.CreateButton or CreateButton, self, options)
	self:AddAuraSlot(key, filter, options)
	return key
end

function elementMixin:ForceUpdate()
	self:UpdateAllAuras()
end

local function Build(parent, options, state)
	local templates = 'CustomAuraContainerTemplate'
	if options and options.templates then templates = templates .. ',' .. options.templates end
	local element = CreateFrame('AuraContainer', nil, parent or UIParent, templates)
	element.__owner = parent
	element.__state = state or {groupIndex = 0, slotIndex = 0}
	Mixin(element, elementMixin)
	if not parent then element:SetEnabled(false); element:Hide() end
	if options then
		element:SetFlowLayoutAnchorPoint(options.initialAnchor or 'TOPLEFT')
		if options.layout then element:SetFlowLayoutAxis(options.layout) end
		element:SetFlowLayoutMaximumLineSize(options.layoutLimit or 1)
		element:SetFlowLayoutGrowthDirection(options.growthX == 'LEFT' and -1 or 1, options.growthY == 'DOWN' and -1 or 1)
		element:SetFlowLayoutPadding(options.paddingLeft or options.padding or 0, options.paddingRight or options.padding or 0, options.paddingTop or options.padding or 0, options.paddingBottom or options.padding or 0)
		if options.policy then element:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura, options.policy) end
	end
	if options and options.initialize then options.initialize(element) end
	return element
end

function oUF:PrewarmAuras(options)
	argcheck(options, 2, 'table')
	if InCombatLockdown() then return end
	local pool = POOLS[options] or {}
	POOLS[options] = pool
	pool[#pool + 1] = Build(nil, options)
end

local function Create(self, options)
	STATE[self] = STATE[self] or {elements = {}}
	local state = STATE[self]
	local pool = options and POOLS[options]
	local element = pool and table.remove(pool)
	if element then
		element.__owner = self
		element:SetParent(self)
		element:SetFrameLevel(self:GetFrameLevel() + 1)
		element:Show()
	else
		element = Build(self, options, {groupIndex = 0, slotIndex = 0})
	end
	state.elements[#state.elements + 1] = element
	return element
end

local function Update(self, event)
	local state = STATE[self]
	if not state then return end
	for _, element in next, state.elements do
		if element:GetUnit() ~= self.__unit then element:SetUnit(self.__unit) else element:ForceUpdate() end
		if element.PostUpdate then element:PostUpdate(event) end
	end
end

local function Enable(self)
	local state = STATE[self]
	if not state then return end
	for _, element in next, state.elements do element:SetEnabled(true) end
	return true
end

local function Disable(self)
	local state = STATE[self]
	if not state then return end
	for _, element in next, state.elements do element:SetEnabled(false) end
end

oUF:AddMetaElement('PrewarmAuras', Create, Update, Enable, Disable)
