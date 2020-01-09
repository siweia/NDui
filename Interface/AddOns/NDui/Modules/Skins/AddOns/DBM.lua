local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local strfind, strmatch, gsub = string.find, string.match, string.gsub

function S:DBMSkin()
	-- Default notice message
	local RaidNotice_AddMessage_ = RaidNotice_AddMessage
	RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
		if strfind(textString, "|T") then
            if strmatch(textString, ":(%d+):(%d+)") then
                local size1, size2 = strmatch(textString, ":(%d+):(%d+)")
                size1, size2 = size1 + 3, size2 + 3
                textString = gsub(textString,":(%d+):(%d+)",":"..size1..":"..size2..":0:0:64:64:5:59:5:59")
            elseif strmatch(textString, ":(%d+)|t") then
                local size = strmatch(textString, ":(%d+)|t")
                size = size + 3
                textString = gsub(textString,":(%d+)|t",":"..size..":"..size..":0:0:64:64:5:59:5:59|t")
            end
		end
		return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
	end

	if not IsAddOnLoaded("DBM-Core") then return end
	if not NDuiDB["Skins"]["DBM"] then return end

	local buttonsize = 24
	local function SkinBars(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				local frame		= bar.frame
				local tbar		= _G[frame:GetName().."Bar"]
				local spark		= _G[frame:GetName().."BarSpark"]
				local texture	= _G[frame:GetName().."BarTexture"]
				local icon1		= _G[frame:GetName().."BarIcon1"]
				local icon2		= _G[frame:GetName().."BarIcon2"]
				local name		= _G[frame:GetName().."BarName"]
				local timer		= _G[frame:GetName().."BarTimer"]

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				if bar.enlarged then
					frame:SetWidth(bar.owner.options.HugeWidth)
					tbar:SetWidth(bar.owner.options.HugeWidth)
				else
					frame:SetWidth(bar.owner.options.Width)
					tbar:SetWidth(bar.owner.options.Width)
				end

				if not frame.styled then
					frame:SetScale(1)
					frame.SetScale = B.Dummy
					frame:SetHeight(buttonsize/2)
					frame.SetHeight = B.Dummy
					frame.styled = true
				end

				if not spark.killed then
					spark:SetAlpha(0)
					spark:SetTexture(nil)
					spark.killed = true
				end

				if not icon1.styled then
					icon1:SetSize(buttonsize, buttonsize)
					icon1.SetSize = B.Dummy
					B.ReskinIcon(icon1)
					icon1:ClearAllPoints()
					icon1:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -5, 0)
					icon1.styled = true
				end

				if not icon2.styled then
					icon2:SetSize(buttonsize, buttonsize)
					icon2.SetSize = B.Dummy
					B.ReskinIcon(icon2)
					icon2:ClearAllPoints()
					icon2:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -5, 0)
					icon2.styled = true
				end

				if not texture.styled then
					texture:SetTexture(DB.normTex)
					texture.styled = true
				end

				tbar:SetStatusBarTexture(DB.normTex)
				if not tbar.styled then
					B.StripTextures(tbar)
					B.SetBD(tbar)
					tbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
					tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
					tbar.SetPoint = B.Dummy
					tbar.styled = true

					tbar.Spark = tbar:CreateTexture(nil, "OVERLAY")
					tbar.Spark:SetTexture(DB.sparkTex)
					tbar.Spark:SetBlendMode("ADD")
					tbar.Spark:SetAlpha(.8)
					tbar.Spark:SetPoint("TOPLEFT", tbar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
					tbar.Spark:SetPoint("BOTTOMRIGHT", tbar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)
				end

				if not name.styled then
					name:ClearAllPoints()
					name:SetPoint("LEFT", frame, "LEFT", 2, 8)
					name:SetPoint("RIGHT", frame, "LEFT", tbar:GetWidth()*.85, 8)
					name.SetPoint = B.Dummy
					name:SetFont(DB.Font[1], 14, DB.Font[3])
					name.SetFont = B.Dummy
					name:SetJustifyH("LEFT")
					name:SetWordWrap(false)
					name:SetShadowColor(0, 0, 0, 0)
					name.styled = true
				end

				if not timer.styled then
					timer:ClearAllPoints()
					timer:SetPoint("RIGHT", frame, "RIGHT", -2, 8)
					timer.SetPoint = B.Dummy
					timer:SetFont(DB.Font[1], 14, DB.Font[3])
					timer.SetFont = B.Dummy
					timer:SetJustifyH("RIGHT")
					timer:SetShadowColor(0, 0, 0, 0)
					timer.styled = true
				end

				if bar.owner.options.IconLeft then icon1:Show() else icon1:Hide() end
				if bar.owner.options.IconRight then icon2:Show() else icon2:Hide() end
				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				texture:SetAlpha(1)
				frame:Show()
				bar:Update(0)
				bar.injected = true
			end
		end
	end
	hooksecurefunc(DBT, "CreateBar", SkinBars)

	local function SkinRange()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			TT.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			TT.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end
	hooksecurefunc(DBM.RangeCheck, "Show", SkinRange)

	if DBM.InfoFrame then
		DBM.InfoFrame:Show(5, "test")
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript("OnShow", TT.ReskinTooltip)
	end

	-- Force Settings
	if not DBM_AllSavedOptions["Default"] then DBM_AllSavedOptions["Default"] = {} end
	DBM_AllSavedOptions["Default"]["BlockVersionUpdateNotice"] = true
	DBM_AllSavedOptions["Default"]["EventSoundVictory"] = "None"
	DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 15
	DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 15
	if IsAddOnLoaded("DBM-VPYike") then
		DBM_AllSavedOptions["Default"]["CountdownVoice"] = "VP:Yike"
		DBM_AllSavedOptions["Default"]["ChosenVoicePack"] = "Yike"
	end
end