local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Credit: ShestakUI
local atlasColors = {
	["UI-Frame-Bar-Fill-Blue"] = {.2, .6, 1},
	["UI-Frame-Bar-Fill-Red"] = {.9, .2, .2},
	["UI-Frame-Bar-Fill-Yellow"] = {1, .6, 0},
	["objectivewidget-bar-fill-left"] = {.2, .6, 1},
	["objectivewidget-bar-fill-right"] = {.9, .2, .2}
}

local function updateBarTexture(self, atlas)
	if atlasColors[atlas] then
		self:SetStatusBarTexture(DB.normTex)
		self:SetStatusBarColor(unpack(atlasColors[atlas]))
	end
end

local function ReskinWidgetStatusBar(self)
	local bar = self.Bar
	local atlas = bar:GetStatusBarAtlas()
	updateBarTexture(bar, atlas)

	if not bar.styled then
		bar.BGLeft:SetAlpha(0)
		bar.BGRight:SetAlpha(0)
		bar.BGCenter:SetAlpha(0)
		bar.BorderLeft:SetAlpha(0)
		bar.BorderRight:SetAlpha(0)
		bar.BorderCenter:SetAlpha(0)
		bar.Spark:SetAlpha(0)
		B.SetBD(bar)

		bar.styled = true
	end
end

local Type_StatusBar = _G.Enum.UIWidgetVisualizationType.StatusBar
local Type_SpellDisplay = _G.Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar

local function ReskinWidgetFrames()
	for _, widgetFrame in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
		local widgetType = widgetFrame.widgetType
		if widgetType == Type_DoubleStatusBar then
			if not widgetFrame.styled then
				for _, bar in pairs({widgetFrame.LeftBar, widgetFrame.RightBar}) do
					bar.BG:SetAlpha(0)
					bar.BorderLeft:SetAlpha(0)
					bar.BorderRight:SetAlpha(0)
					bar.BorderCenter:SetAlpha(0)
					bar.Spark:SetAlpha(0)
					bar.SparkGlow:SetAlpha(0)
					bar.BorderGlow:SetAlpha(0)
					B.SetBD(bar)
					hooksecurefunc(bar, "SetStatusBarAtlas", updateBarTexture)
				end

				widgetFrame.styled = true
			end
		elseif widgetType == Type_SpellDisplay then
			if not widgetFrame.styled then
				local widgetSpell = widgetFrame.Spell
				widgetSpell.IconMask:Hide()
				widgetSpell.Border:SetTexture(nil)
				widgetSpell.DebuffBorder:SetTexture(nil)
				B.ReskinIcon(widgetSpell.Icon)

				widgetFrame.styled = true
			end
		elseif widgetType == Type_StatusBar then
			ReskinWidgetStatusBar(widgetFrame)
		end
	end
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	B:RegisterEvent("PLAYER_ENTERING_WORLD", ReskinWidgetFrames)
	B:RegisterEvent("UPDATE_ALL_UI_WIDGETS", ReskinWidgetFrames)

	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", ReskinWidgetStatusBar)

	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, "Setup", function(self)
		self.LeftLine:SetAlpha(0)
		self.RightLine:SetAlpha(0)
		self.BarBackground:SetAlpha(0)
		self.Glow1:SetAlpha(0)
		self.Glow2:SetAlpha(0)
		self.Glow3:SetAlpha(0)

		self.LeftBar:SetTexture(DB.normTex)
		self.NeutralBar:SetTexture(DB.normTex)
		self.RightBar:SetTexture(DB.normTex)

		self.LeftBar:SetVertexColor(.2, .6, 1)
		self.NeutralBar:SetVertexColor(.8, .8, .8)
		self.RightBar:SetVertexColor(.9, .2, .2)

		if not self.bg then
			self.bg = B.SetBD(self)
			self.bg:SetPoint("TOPLEFT", self.LeftBar, -2, 2)
			self.bg:SetPoint("BOTTOMRIGHT", self.RightBar, 2, -2)
		end
	end)
end)