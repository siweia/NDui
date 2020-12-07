local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Credit: ElvUI
local ipairs = ipairs
local UIWidgetSetLayoutDirection = Enum.UIWidgetSetLayoutDirection
local UIWidgetLayoutDirection = Enum.UIWidgetLayoutDirection

local function reskinWidgetBar(bar)
	if bar and bar.BGLeft and not bar.styled then
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

local function FixDefaultAnchor(self)
	-- GetExtents will also fail if the LayoutFrame has no anchors set, so if that is the case, set an anchor and then clear it after we are done
	local hadNoAnchors = (self:GetNumPoints() == 0)
	if hadNoAnchors then
		self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
	end
end

function B.Widget_DefaultLayout(widgetContainerFrame, sortedWidgets)
	local horizontalRowContainer = nil

	-- GetExtents will fail if the LayoutFrame has 0 width or height, so set them to 1 to start
	local horizontalRowHeight = 1
	local horizontalRowWidth = 1
	local totalWidth = 1
	local totalHeight = 1

	widgetContainerFrame.horizontalRowContainerPool:ReleaseAll()

	for index, widgetFrame in ipairs(sortedWidgets) do
		widgetFrame:ClearAllPoints()
		reskinWidgetBar(widgetFrame.Bar)

		local widgetSetUsesVertical = widgetContainerFrame.widgetSetLayoutDirection == UIWidgetSetLayoutDirection.Vertical
		local widgetUsesVertical = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Vertical

		local useOverlapLayout = widgetFrame.layoutDirection == UIWidgetLayoutDirection.Overlap
		local useVerticalLayout = widgetUsesVertical or (widgetFrame.layoutDirection == UIWidgetLayoutDirection.Default and widgetSetUsesVertical)

		if useOverlapLayout then
			-- This widget uses overlap layout

			if index == 1 then
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, widgetContainerFrame)
				end
			else
				local relative = sortedWidgets[index - 1]
				if widgetSetUsesVertical then
					widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalAnchorPoint, 0, 0)
				else
					widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalAnchorPoint, 0, 0)
				end
			end

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			if height > totalHeight then
				totalHeight = height
			end

			widgetFrame:SetParent(widgetContainerFrame)
		elseif useVerticalLayout then
			if index == 1 then
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame)
			else
				local relative = horizontalRowContainer or sortedWidgets[index - 1]
				widgetFrame:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

				if horizontalRowContainer then
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					FixDefaultAnchor(horizontalRowContainer)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
					horizontalRowContainer = nil
				end

				totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
			end

			widgetFrame:SetParent(widgetContainerFrame)

			local width, height = widgetFrame:GetSize()
			if width > totalWidth then
				totalWidth = width
			end
			totalHeight = totalHeight + height
		else
			local forceNewRow = widgetFrame.layoutDirection == UIWidgetLayoutDirection.HorizontalForceNewRow
			local needNewRowContainer = not horizontalRowContainer or forceNewRow
			if needNewRowContainer then
				if horizontalRowContainer then
					horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
					FixDefaultAnchor(horizontalRowContainer)
					totalWidth = totalWidth + horizontalRowWidth
					totalHeight = totalHeight + horizontalRowHeight
					horizontalRowHeight = 0
					horizontalRowWidth = 0
				end

				local newHorizontalRowContainer = widgetContainerFrame.horizontalRowContainerPool:Acquire()
				newHorizontalRowContainer:Show()

				if index == 1 then
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, widgetContainerFrame, widgetContainerFrame.verticalAnchorPoint)
				else
					local relative = horizontalRowContainer or sortedWidgets[index - 1]
					newHorizontalRowContainer:SetPoint(widgetContainerFrame.verticalAnchorPoint, relative, widgetContainerFrame.verticalRelativePoint, 0, widgetContainerFrame.verticalAnchorYOffset)

					totalHeight = totalHeight + widgetContainerFrame.verticalAnchorYOffset
				end
				widgetFrame:SetPoint('TOPLEFT', newHorizontalRowContainer)
				widgetFrame:SetParent(newHorizontalRowContainer)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth()
				horizontalRowContainer = newHorizontalRowContainer
			else
				local relative = sortedWidgets[index - 1]
				widgetFrame:SetParent(horizontalRowContainer)
				widgetFrame:SetPoint(widgetContainerFrame.horizontalAnchorPoint, relative, widgetContainerFrame.horizontalRelativePoint, widgetContainerFrame.horizontalAnchorXOffset, 0)

				horizontalRowWidth = horizontalRowWidth + widgetFrame:GetWidth() + widgetContainerFrame.horizontalAnchorXOffset
			end

			local widgetHeight = widgetFrame:GetHeight()
			if widgetHeight > horizontalRowHeight then
				horizontalRowHeight = widgetHeight
			end
		end
	end

	if horizontalRowContainer then
		horizontalRowContainer:SetSize(horizontalRowWidth, horizontalRowHeight)
		FixDefaultAnchor(horizontalRowContainer)
		totalWidth = totalWidth + horizontalRowWidth
		totalHeight = totalHeight + horizontalRowHeight
	end

	widgetContainerFrame:SetSize(totalWidth, totalHeight)
	FixDefaultAnchor(widgetContainerFrame)
end