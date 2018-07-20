local _, ns = ...
local B, C, L, DB = unpack(ns)
local module = B:RegisterModule("Cooldown")

function module:OnLogin()
	if not NDuiDB["Actionbar"]["Cooldown"] then return end

	local FONT_SIZE = 19
	local MIN_DURATION = 2.5                    -- the minimum duration to show cooldown text for
	local MIN_SCALE = 0.5                       -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
	local ICON_SIZE = 36
	local GetTime = GetTime

	-- stops the timer
	local function Timer_Stop(self)
		self.enabled = nil
		self:Hide()
	end

	-- forces the given timer to update on the next frame
	local function Timer_ForceUpdate(self)
		self.nextUpdate = 0
		self:Show()
	end

	-- adjust font size whenever the timer's parent size changes, hide if it gets too tiny
	local function Timer_OnSizeChanged(self, width)
		local fontScale = floor(width + 0.5) / ICON_SIZE
		if fontScale == self.fontScale then return end
		self.fontScale = fontScale

		if fontScale < MIN_SCALE then
			self:Hide()
		else
			self.text:SetFont(DB.Font[1], fontScale * FONT_SIZE, DB.Font[3])
			self.text:SetShadowColor(0, 0, 0, 0)

			if self.enabled then
				Timer_ForceUpdate(self)
			end
		end
	end

	-- update timer text, if it needs to be, hide the timer if done
	local function Timer_OnUpdate(self, elapsed)
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			local remain = self.duration - (GetTime() - self.start)
			if remain > 0 then
				local time, nextUpdate = B.FormatTime(remain)
				self.text:SetText(time)
				self.nextUpdate = nextUpdate
			else
				Timer_Stop(self)
			end
		end
	end

	-- returns a new timer object
	local function Timer_Create(self)
		local scaler = CreateFrame("Frame", nil, self)
		scaler:SetAllPoints(self)

		local timer = CreateFrame("Frame", nil, scaler)
		timer:Hide()
		timer:SetAllPoints(scaler)
		timer:SetScript("OnUpdate", Timer_OnUpdate)

		local text = timer:CreateFontString(nil, "BACKGROUND")
		text:SetPoint("CENTER", 2, 0)
		text:SetJustifyH("CENTER")
		timer.text = text

		Timer_OnSizeChanged(timer, scaler:GetSize())
		scaler:SetScript("OnSizeChanged", function(_, ...) 
			Timer_OnSizeChanged(timer, ...) 
		end)

		self.timer = timer
		return timer
	end

	local function Timer_Start(self, start, duration)
		if self:IsForbidden() then return end
		if self:GetParent():GetParent() == PVPQueueFrame then return end
		if self.noOCC then return end

		if start > 0 and duration > MIN_DURATION then
			local timer = self.timer or Timer_Create(self)
			timer.start = start
			timer.duration = duration
			timer.enabled = true
			timer.nextUpdate = 0

			if timer.fontScale >= MIN_SCALE then 
				timer:Show()
			end
		else
			local timer = self.timer
			if timer then Timer_Stop(timer) end
		end
	end
	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", Timer_Start)

	local active, hooked = {}, {}

	local function Cooldown_OnShow(self)
		active[self] = true
	end

	local function Cooldown_OnHide(self)
		active[self] = nil
	end

	local function Cooldown_ShouldUpdateTimer(self, start)
		local timer = self.timer
		if not timer then
			return true
		end
		return timer.start ~= start
	end

	local function Cooldown_Update(self)
		local button = self:GetParent()
		local start, duration = GetActionCooldown(button.action)

		if Cooldown_ShouldUpdateTimer(self, start) then
			Timer_Start(self, start, duration)
		end
	end

	B:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", function()
		for cooldown in pairs(active) do
			Cooldown_Update(cooldown)
		end
	end)

	local function ActionButton_Register(frame)
		local cooldown = frame.cooldown
		if not hooked[cooldown] then
			cooldown:HookScript("OnShow", Cooldown_OnShow)
			cooldown:HookScript("OnHide", Cooldown_OnHide)
			hooked[cooldown] = true
		end
	end

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			ActionButton_Register(frame)
		end
	end
	hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", ActionButton_Register)

	-- Hide Default Cooldown
	SetCVar("countdownForCooldowns", 0)
	B.HideOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end