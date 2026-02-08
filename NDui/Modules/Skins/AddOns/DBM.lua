local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local strfind, strmatch, gsub = string.find, string.match, string.gsub

local buttonsize = 24

local function ReskinDBMIcon(icon, frame)
	if not icon then return end
	if not icon.styled then
		icon:SetSize(buttonsize, buttonsize)
		icon.SetSize = B.Dummy

		local bg = B.ReskinIcon(icon, true)
		bg.icon = bg:CreateTexture(nil, "ARTWORK")
		bg.icon:SetInside()
		bg.icon:SetTexture(icon:GetTexture())
		bg.icon:SetTexCoord(unpack(DB.TexCoord))

		icon.styled = true
	end
	icon:ClearAllPoints()
	icon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -2, 2)
end

local function ReskinDBMBar(bar, frame)
	if not bar then return end
	if not bar.styled then
		B.StripTextures(bar)
		B.CreateSB(bar, true)

		bar.styled = true
	end
	bar:SetInside(frame, 2, 2)
end

local function HideDBMSpark(self)
	local spark = _G[self.frame:GetName().."BarSpark"]
	spark:SetAlpha(0)
	spark:SetTexture(nil)
end

local function ApplyDBMStyle(self)
	local frame = self.frame
	local frame_name = frame:GetName()
	local tbar = _G[frame_name.."Bar"]
	local texture = _G[frame_name.."BarTexture"]
	local icon1 = _G[frame_name.."BarIcon1"]
	local icon2 = _G[frame_name.."BarIcon2"]
	local name = _G[frame_name.."BarName"]
	local timer = _G[frame_name.."BarTimer"]

	if self.enlarged then
		frame:SetWidth(self.owner.Options.HugeWidth)
		tbar:SetWidth(self.owner.Options.HugeWidth)
	else
		frame:SetWidth(self.owner.Options.Width)
		tbar:SetWidth(self.owner.Options.Width)
	end

	frame:SetScale(1)
	frame:SetHeight(buttonsize/2)

	ReskinDBMIcon(icon1, frame)
	ReskinDBMIcon(icon2, frame)
	ReskinDBMBar(tbar, frame)
	if texture then texture:SetTexture(DB.normTex) end

	name:ClearAllPoints()
	name:SetPoint("LEFT", frame, "LEFT", 2, 8)
	name:SetPoint("RIGHT", frame, "LEFT", tbar:GetWidth()*.85, 8)
	B.SetFontSize(name, 14)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	name:SetShadowColor(0, 0, 0, 0)

	timer:ClearAllPoints()
	timer:SetPoint("RIGHT", frame, "RIGHT", -2, 8)
	B.SetFontSize(timer, 14)
	timer:SetJustifyH("RIGHT")
	timer:SetShadowColor(0, 0, 0, 0)
end

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
	if not C.db["Skins"]["DBM"] then return end
	if not DBM.Options then return end

	hooksecurefunc(DBT, "CreateBar", function(self)
		for bar in self:GetBarIterator() do
			if not bar.injected then
				hooksecurefunc(bar, "Update", HideDBMSpark)
				hooksecurefunc(bar, "ApplyStyle", ApplyDBMStyle)
				bar:ApplyStyle()

				bar.injected = true
			end
		end
	end)

	hooksecurefunc(DBM.RangeCheck, "Show", function()
		if DBMRangeCheckRadar and not DBMRangeCheckRadar.styled then
			TT.ReskinTooltip(DBMRangeCheckRadar)
			DBMRangeCheckRadar.styled = true
		end

		if DBMRangeCheck and not DBMRangeCheck.styled then
			TT.ReskinTooltip(DBMRangeCheck)
			DBMRangeCheck.styled = true
		end
	end)

	if DBM.InfoFrame then
		DBM.InfoFrame:Show(5, "test")
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript("OnShow", TT.ReskinTooltip)
	end

	-- Force Settings
	if not DBM_AllSavedOptions["Default"] then DBM_AllSavedOptions["Default"] = {} end
	DBM_AllSavedOptions["Default"]["BlockVersionUpdateNotice"] = true
	DBM_AllSavedOptions["Default"]["EventSoundVictory"] = "None"
	if IsAddOnLoaded("DBM-VPYike") then
		DBM_AllSavedOptions["Default"]["CountdownVoice"] = "VP:Yike"
		DBM_AllSavedOptions["Default"]["ChosenVoicePack"] = "Yike"
	end
	if not DBT_AllPersistentOptions["Default"] then DBT_AllPersistentOptions["Default"] = {} end
	DBT_AllPersistentOptions["Default"]["DBM"].BarYOffset = 8
	DBT_AllPersistentOptions["Default"]["DBM"].HugeBarYOffset = 8
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwards = true
	DBT_AllPersistentOptions["Default"]["DBM"].ExpandUpwardsLarge = true
end