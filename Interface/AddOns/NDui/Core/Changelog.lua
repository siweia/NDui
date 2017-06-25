local B, C, L, DB = unpack(select(2, ...))
if DB.Client ~= "zhCN" then return end

local hx = {
	"Aurora更新对AngryKeystones日程表的美化；",
	"聊天背景会跟随聊天框的上下拉升变化；",
	"优化团队框体快速战复的功能；",
	"动作条调整；",
	"更新技能监视列表；",
	"更新萨墓的团队框体法术；",
	"背包细节微调。",
}

local function changelog()
	local f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetScale(1.2)
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.CreateBD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 25)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 12)
	B.CreateFS(f, 16, L["Changelog"], true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, f)
	ll:SetPoint("TOP", -51, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", 0, 0, 0, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, f)
	lr:SetPoint("TOP", 51, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", 0, 0, 0, .7, 0)
	lr:SetFrameStrata("HIGH")
	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 12, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 20
	end
	f:SetSize(400, 60 + offset)
	local close = CreateFrame("Button", nil, f)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetSize(20, 20)
	B.CreateBD(close, .3)
	B.CreateFS(close, 12, "X", true)
	B.CreateBC(close)
	close:SetScript("OnClick", function(self) f:Hide() end)
end

NDui:EventFrame("PLAYER_ENTERING_WORLD"):SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()

	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end
	if (not HelloWorld) and NDuiADB["Changelog"].Version ~= DB.Version then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end
end)

SlashCmdList["NDUICHANGELOG"] = function()
	if not NDuiChangeLog then changelog() else NDuiChangeLog:Show() end
end
SLASH_NDUICHANGELOG1 = '/ncl'