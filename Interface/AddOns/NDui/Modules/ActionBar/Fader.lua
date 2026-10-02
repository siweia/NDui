local _, ns = ...
local B, C, L, DB = unpack(ns)
local Bar = B:GetModule("Actionbar")
local LAB = LibStub("LibActionButton-1.0-NDui")

local tinsert, wipe = tinsert, table.wipe

-- Action bars that can fade when not moused over. Bar3 is split left/right
-- around the main bar, so it may contribute two frames.
local fadable = {
	{key = "Bar1", frame = "NDui_ActionBar1"},
	{key = "Bar2", frame = "NDui_ActionBar2"},
	{key = "Bar3", frame = "NDui_ActionBar3"},
	{key = "Bar4", frame = "NDui_ActionBar4"},
	{key = "Bar5", frame = "NDui_ActionBar5"},
	{key = "Bar6", frame = "NDui_ActionBar6"},
	{key = "Bar7", frame = "NDui_ActionBar7"},
	{key = "Bar8", frame = "NDui_ActionBar8"},
	{key = "BarPet", frame = "NDui_ActionBarPet"},
	{key = "BarStance", frame = "NDui_ActionBarStance"},
	-- Blizzard's micro menu is split across frames; NDui's menubar replaces them when enabled
	{key = "MicroMenu", getFrame = function() return Bar.menubar end},
	{key = "MicroMenu", frame = "MicroMenu"},
	{key = "MicroMenu", frame = "BagsBar"},
}

local watched = {}
local elapsed = 0

local driver = CreateFrame("Frame", nil, UIParent)
driver:Hide()
driver:SetScript("OnUpdate", function(_, delta)
	elapsed = elapsed + delta
	if elapsed < .15 then return end
	elapsed = 0
	Bar:UpdateFadeAlpha()
end)

local function getFadedAlpha(key)
	local alpha = C.db["Actionbar"][key.."FadeAlpha"]
	if not alpha then alpha = 20 end
	return alpha / 100
end

local function isFlyoutHovered()
	local flyout = _G.SpellFlyout
	if flyout and flyout:IsShown() and flyout:IsMouseOver(1, -1, -1, 1) then
		return true
	end

	flyout = LAB and LAB.flyoutHandler
	if flyout and flyout.IsShown and flyout:IsShown() and flyout:IsMouseOver(1, -1, -1, 1) then
		return true
	end

	return false
end

-- The whole bar rectangle counts as hover, not just buttons with actions,
-- so empty slots, gaps and padding reveal the bar too.
function Bar:UpdateFadeAlpha()
	local revealAll = C.db["Actionbar"]["FadeRevealAll"]
	local flyoutHovered = isFlyoutHovered()
	local hovered, anyHovered = {}, flyoutHovered
	local moversShown = false

	for i = 1, #watched do
		local entry = watched[i]
		local frame = entry.frame
		-- frames sharing a key (bar halves, micro menu pieces) reveal as one bar
		if frame:IsShown() and frame:IsMouseOver(1, -1, -1, 1) then
			hovered[entry.key] = true
			anyHovered = true
		end

		local mover = frame.mover
		if mover and mover:IsShown() then
			moversShown = true
		end
	end

	local showAll = moversShown or (revealAll and anyHovered)
	for i = 1, #watched do
		local entry = watched[i]
		local show = showAll or (not revealAll and (flyoutHovered or hovered[entry.key]))
		local alpha = show and 1 or getFadedAlpha(entry.key)
		if entry.frame:GetAlpha() ~= alpha then
			entry.frame:SetAlpha(alpha)
		end
	end
end

function Bar:UpdateFade()
	for i = 1, #watched do
		watched[i].frame:SetAlpha(1)
	end
	wipe(watched)

	local db = C.db["Actionbar"]
	for _, info in ipairs(fadable) do
		local frame
		if info.getFrame then
			frame = info.getFrame()
		else
			frame = _G[info.frame]
		end
		if frame and db[info.key.."Fade"] then
			tinsert(watched, {key = info.key, frame = frame})

			-- Bar3's right half lives in a child frame, when it is in use
			if frame.child and frame.child.mover and not frame.child.mover.isDisable then
				tinsert(watched, {key = info.key, frame = frame.child})
			end
		end
	end

	if #watched > 0 then
		elapsed = 0
		driver:Show()
	else
		driver:Hide()
	end
	Bar:UpdateFadeAlpha()
end
