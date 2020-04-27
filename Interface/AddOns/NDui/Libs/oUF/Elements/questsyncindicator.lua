local _, ns = ...
local oUF = ns.oUF

local C_QuestSession_HasJoined = C_QuestSession.HasJoined

local function Update(self, event)
	local element = self.QuestSyncIndicator

	--[[ Callback: QuestSyncIndicator:PreUpdate()
	Called before the element has been updated.

	* self - the QuestSyncIndicator element
	--]]
	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local hasJoined = C_QuestSession_HasJoined()
	if(hasJoined) then
		element:Show()
	else
		element:Hide()
	end

	--[[ Callback: QuestSyncIndicator:PostUpdate(hasJoined)
	Called after the element has been updated.

	* self        - the QuestSyncIndicator element
	* hasJoined - indicates if the element is shown (boolean)
	--]]
	if(element.PostUpdate) then
		return element:PostUpdate(hasJoined)
	end
end

local function Path(self, ...)
	--[[ Override: QuestSyncIndicator.Override(self, event, ...)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	* ...   - the arguments accompanying the event
	--]]
	return (self.QuestSyncIndicator.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.QuestSyncIndicator
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_ENTERING_WORLD', Path, true)
		self:RegisterEvent('QUEST_SESSION_JOINED', Path, true)
		self:RegisterEvent('QUEST_SESSION_LEFT', Path, true)

		if(element:IsObjectType('Texture') and not element:GetTexture()) then
			element:SetAtlas('QuestSharing-DialogIcon')
		end

		return true
	end
end

local function Disable(self)
	local element = self.QuestSyncIndicator
	if(element) then
		element:Hide()

		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)
		self:UnregisterEvent('QUEST_SESSION_JOINED', Path)
		self:UnregisterEvent('QUEST_SESSION_LEFT', Path)
	end
end

oUF:AddElement('QuestSyncIndicator', Path, Enable, Disable)