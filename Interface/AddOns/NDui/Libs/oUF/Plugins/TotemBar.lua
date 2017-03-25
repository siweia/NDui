local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then return end

-- In the order, fire, earth, water, air
local colors = {
	[1] = {.58,.23,.10},
	[2] = {.23,.45,.13},		
	[3] = {.19,.48,.60},
	[4] = {.42,.18,.74},	
}

local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime
	
local function UpdateSlot(self, slot)
	local totem = self.TotemBar
	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
	totem[slot]:SetStatusBarColor(unpack(totem.colors[slot]))
	totem[slot]:SetValue(0)
	
	-- If we have a totem then set his value				
	if duration > 0 then
		-- Status bar update
		totem[slot]:SetAlpha(1)
		totem[slot]:SetMinMaxValues(0, duration)
		totem[slot]:SetScript("OnUpdate", function(self,elapsed)
			local Timer = startTime + duration - GetTime() + 1
			if Timer > 0 then
				self:SetValue(Timer)
				if self.Time then
					self.Time:SetFormattedText("%d", Timer)
				end
			end
		end)
	else
		-- There's no need to update because it doesn't have any duration
		totem[slot]:SetAlpha(0.25)
		totem[slot]:SetMinMaxValues(0, 1)
		totem[slot]:SetScript("OnUpdate", nil)
		totem[slot]:SetValue(1)
		if totem[slot].Time then totem[slot].Time:SetText("") end
	end
end

local function Update(self, unit)
	-- Update every slot on login, still have issues with it
	for i = 1, 4 do 
		UpdateSlot(self, i)
	end
end

local function Event(self, event, i)
	if event == "PLAYER_TOTEM_UPDATE" then
		for i = 1, 4 do
			UpdateSlot(self, i)
		end
	end
end

local function Enable(self, unit)
	local totem = self.TotemBar
	
	if(totem) then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE" , Event, true)
		totem.colors = setmetatable(totem.colors or {}, {__index = colors})
		TotemFrame:UnregisterAllEvents()
		return true
	end	
end

local function Disable(self,unit)
	local totem = self.TotemBar
	if(totem) then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Event)
		
		TotemFrame:Show()
	end
end

oUF:AddElement("TotemBar", Update, Enable, Disable)