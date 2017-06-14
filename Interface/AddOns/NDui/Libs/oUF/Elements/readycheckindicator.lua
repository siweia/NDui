local _, ns = ...
local oUF = ns.oUF

local function OnFinished(self)
	local element = self:GetParent()
	element:Hide()

	if(element.PostUpdateFadeOut) then
		element:PostUpdateFadeOut()
	end
end

local function Update(self, event)
	local element = self.ReadyCheckIndicator

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local unit = self.unit
	local status = GetReadyCheckStatus(unit)
	if(UnitExists(unit) and status) then
		if(status == 'ready') then
			element:SetTexture(element.readyTexture)
		elseif(status == 'notready') then
			element:SetTexture(element.notReadyTexture)
		else
			element:SetTexture(element.waitingTexture)
		end

		element.status = status
		element:Show()
	elseif(event ~= 'READY_CHECK_FINISHED') then
		element.status = nil
		element:Hide()
	end

	if(event == 'READY_CHECK_FINISHED') then
		if(element.status == 'waiting') then
			element:SetTexture(element.notReadyTexture)
		end

		element.Animation:Play()
	end

	if(element.PostUpdate) then
		return element:PostUpdate(status)
	end
end

local function Path(self, ...)
	return (self.ReadyCheckIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local element = self.ReadyCheckIndicator
	if(element and (unit and (unit:sub(1, 5) == 'party' or unit:sub(1,4) == 'raid'))) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.readyTexture = element.readyTexture or READY_CHECK_READY_TEXTURE
		element.notReadyTexture = element.notReadyTexture or READY_CHECK_NOT_READY_TEXTURE
		element.waitingTexture = element.waitingTexture or READY_CHECK_WAITING_TEXTURE

		local AnimationGroup = element:CreateAnimationGroup()
		AnimationGroup:HookScript('OnFinished', OnFinished)
		element.Animation = AnimationGroup

		local Animation = AnimationGroup:CreateAnimation('Alpha')
		Animation:SetFromAlpha(1)
		Animation:SetToAlpha(0)
		Animation:SetDuration(element.fadeTime or 1.5)
		Animation:SetStartDelay(element.finishedTime or 10)

		self:RegisterEvent('READY_CHECK', Path, true)
		self:RegisterEvent('READY_CHECK_CONFIRM', Path, true)
		self:RegisterEvent('READY_CHECK_FINISHED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.ReadyCheckIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('READY_CHECK', Path)
		self:UnregisterEvent('READY_CHECK_CONFIRM', Path)
		self:UnregisterEvent('READY_CHECK_FINISHED', Path)
	end
end

oUF:AddElement('ReadyCheckIndicator', Path, Enable, Disable)