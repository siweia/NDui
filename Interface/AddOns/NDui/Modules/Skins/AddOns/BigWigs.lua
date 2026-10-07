local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")

local function removeStyle(bar)
	bar.candyBarBackdrop:Hide()
	bar.candyBarIconFrameBackdrop:Hide()

	local height = bar:Get("ndui:restoreheight")
	if height then
		bar:SetHeight(height)
		bar:Set("ndui:restoreheight", nil)
	end

	-- Restore the indicator frame anchor that was moved to leave room for the icon
	local indicatorAnchor = bar:Get("ndui:indicatoranchor")
	if indicatorAnchor then
		local indicatorFrame = bar:Get("bigwigs:indicatorFrame")
		if indicatorFrame == indicatorAnchor[1] and indicatorFrame.bar == bar then
			indicatorFrame:ClearAllPoints()
			indicatorFrame:SetPoint(indicatorAnchor[2], indicatorAnchor[3], indicatorAnchor[4], indicatorAnchor[5], indicatorAnchor[6])
		end
		bar:Set("ndui:indicatoranchor", nil)
	end

	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
	bar.candyBarDuration:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("TOPLEFT", bar.candyBarBar, "TOPLEFT", 2, 0)
	bar.candyBarLabel:SetPoint("BOTTOMRIGHT", bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
end

local function styleBar(bar)
	local height = bar:GetHeight()
	bar:Set("ndui:restoreheight", height)
	bar:SetHeight(height/2)
	bar.candyBarBackdrop:Hide()
	-- LibCandyBar resets the status bar anchors when the bar height changes.
	local cbb = bar.candyBarBar
	cbb:ClearAllPoints()
	cbb:SetAllPoints(bar)
	if not bar.styled then
		B.StripTextures(cbb, true)
		B.SetBD(cbb)
		bar.styled = true
	end
	bar:SetTexture(DB.normTex)

	-- Icons may be "secret" in 12.x; release the anchor before moving it out of the bar
	local icon = bar.candyBarIconFrame
	local iconVisible = bar:IsIconVisible()
	local reApplyIcon
	if iconVisible and icon.IsAnchoringSecret and icon:IsAnchoringSecret() then
		reApplyIcon = bar:GetIcon()
		icon:SetToDefaults()
		icon:ClearAllPoints()
	end

	icon:ClearAllPoints()
	if iconVisible then
		if bar:GetIconPosition() == "RIGHT" then
			icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 5, 0)
		else
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -5, 0)
		end
		icon:SetSize(height, height)
		icon:Show()
	end

	bar.candyBarIconFrameBackdrop:Hide()
	if not icon.styled then
		B.SetBD(icon)
		icon.styled = true
	end

	if reApplyIcon then
		icon:SetTexture(reApplyIcon)
		icon:SetTexCoord(.08, .92, .08, .92)
	end

	-- Leave room for the icon when the spell indicators share its side
	local indicatorFrame = bar:Get("bigwigs:indicatorFrame")
	if indicatorFrame and indicatorFrame.bar == bar then
		local point, relativeTo, relativePoint, x, y = indicatorFrame:GetPoint(1)
		local onLeft = point == "BOTTOMRIGHT" and relativePoint == "BOTTOMLEFT"
		local onRight = point == "BOTTOMLEFT" and relativePoint == "BOTTOMRIGHT"
		if relativeTo == bar and (onLeft or onRight) then
			if not bar:Get("ndui:indicatoranchor") then
				bar:Set("ndui:indicatoranchor", {indicatorFrame, point, relativeTo, relativePoint, x, y})
			end

			local iconOnRight = bar:GetIconPosition() == "RIGHT"
			local sameSide = iconVisible and ((onLeft and not iconOnRight) or (onRight and iconOnRight))
			local offset = sameSide and (height + 6) or 2
			indicatorFrame:ClearAllPoints()
			indicatorFrame:SetPoint(point, bar, relativePoint, onLeft and -offset or offset, y)
		end
	end

	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
	bar.candyBarLabel:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 8)
	bar.candyBarDuration:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 8)
end

local styleData = {
	apiVersion = 1,
	version = 4,
	GetSpacing = function(bar) return bar:GetHeight()+5 end,
	spellIndicatorsOffset = 2,
	ApplyStyle = styleBar,
	BarStopped = removeStyle,
	fontSizeNormal = 13,
	fontSizeEmphasized = 14,
	fontOutline = "OUTLINE",
	GetStyleName = function() return "NDui" end,
}

function S:RegisterBWStyle()
	if not C.db["Skins"]["Bigwigs"] then return end
	if not BigWigsAPI then return end

	BigWigsAPI:RegisterBarStyle("NDui", styleData)
	-- Force to use NDui style
	local pending = true
	hooksecurefunc(BigWigsAPI, "GetBarStyle", function()
		if pending then
			BigWigsAPI.GetBarStyle = function() return styleData end
			pending = nil
		end
	end)
end

function S:BigWigsSkin()
	if not C.db["Skins"]["Bigwigs"] then return end

	if BigWigsLoader and BigWigsLoader.RegisterMessage then
		BigWigsLoader.RegisterMessage(_, "BigWigs_FrameCreated", function(_, frame, name)
			if frame and (name == "QueueTimer") and not frame.styled then
				B.StripTextures(frame)
				frame:SetStatusBarTexture(DB.normTex)
				B.SetBD(frame)

				frame.styled = true
			end
		end)
	end
end

S:RegisterSkin("BigWigs", S.BigWigsSkin)
S:RegisterSkin("BigWigs_Plugins", S.RegisterBWStyle)