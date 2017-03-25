local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")

function module:RCLootCoucil()
	if not NDuiDB["Skins"]["RCLC"] then return end
	if not IsAddOnLoaded("RCLootCouncil") then return end

	local parent = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
	local session = parent:GetModule("RCSessionFrame")
	local loot = parent:GetModule("RCLootFrame")
	local voting = parent:GetModule("RCVotingFrame")
	local history = parent:GetModule("RCLootHistory")

	local function ClearAllRegions(frame)
		if not frame then return end
		for i = 1, frame:GetNumRegions() do
			local region = select(i, frame:GetRegions())
			if region and region:GetObjectType() == "Texture" then
				region:Hide()
			end
		end
	end

	local function ReskinButton(bu)
		B.CreateBC(bu)
		B.CreateBD(bu, .3)
	end

	local function TableChecking()
		for i = 1, 5 do
			local scroll = _G["ScrollTable"..i]
			if scroll and not scroll.styled then
				ClearAllRegions(scroll)
				B.CreateBD(scroll)
				scroll.styled = true
			end

			local index = 1
			local row = _G["ScrollTable"..i.."Row"..index]
			while row do
				local icon2 = _G["ScrollTable"..i.."Row"..index.."col2"]
				if icon2 and icon2:GetRegions() then
					icon2:GetRegions():SetTexCoord(unpack(DB.TexCoord))
				end

				local bu = _G["ScrollTable"..i.."Row"..index.."col11"]
				if bu and bu.voteBtn and not bu.styled then
					ReskinButton(bu.voteBtn)
					bu.styled = true
				end

				index = index + 1
				row = _G["ScrollTable"..i.."Row"..index]
			end
		end
	end

	hooksecurefunc(session, "Show", function()
		ClearAllRegions(DefaultRCSessionSetupFrame.content)
		ClearAllRegions(DefaultRCSessionSetupFrame.title)
		B.CreateBD(DefaultRCSessionSetupFrame)
		B.CreateCB(DefaultRCSessionSetupFrameToggle)

		for i = 2, 3 do
			local bu = select(i, DefaultRCSessionSetupFrame.content:GetChildren())
			ReskinButton(bu)
		end
		TableChecking()
	end)

	hooksecurefunc(loot, "Show", function()
		ClearAllRegions(DefaultRCLootFrame.title)
		B.CreateBD(DefaultRCLootFrame.content)
		B.CreateTex(DefaultRCLootFrame.content)

		local i = 1
		local bu = select(i, DefaultRCLootFrame.content:GetChildren())
		while bu do
			bu.icon:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			for j = 1, 4 do
				ReskinButton(bu.buttons[j])
			end
			bu.timeoutBar:SetStatusBarTexture(DB.normTex)

			i = i + 1
			bu = select(i, DefaultRCLootFrame.content:GetChildren())
		end
	end)

	hooksecurefunc(voting, "Show", function()
		local frame = DefaultRCLootCouncilFrame
		ClearAllRegions(frame.title)
		ClearAllRegions(frame.content)
		B.CreateBD(frame.content)
		B.CreateTex(frame.content)
		ReskinButton(frame.abortBtn)
		ReskinButton(frame.filter)
		ReskinButton(frame.disenchant)
		TableChecking()

		local icon = select(2, frame.content:GetChildren())
		icon:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))

		RCVotingFrameMoreInfo:HookScript("OnShow", function(frame)
			if not frame.bg then
				frame:SetBackdrop(nil)
				local bg = CreateFrame("Frame", nil, frame)
				bg:SetAllPoints()
				bg:SetFrameLevel(frame:GetFrameLevel())
				B.CreateBD(bg, .7, 3)
				B.CreateTex(bg)
				frame.bg = bg
			end
		end)
	end)

	hooksecurefunc(voting, "UpdateSessionButton", function()
		local index = 1
		local bu = _G["RCButton"..index]
		while bu do
			bu:GetNormalTexture():SetTexCoord(unpack(DB.TexCoord))
			bu:GetHighlightTexture():SetColorTexture(1, 1, 1, .3)
			bu:SetBackdrop(nil)
			B.CreateSD(bu, 3, 3)

			index = index + 1
			bu = _G["RCButton"..index]
		end
	end)
end