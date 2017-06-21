local B, C, L, DB = unpack(select(2, ...))
if DB.Client ~= "zhCN" then return end

local hx = {
	"更正引导法术的施法条图标；",
	"更新团队框体的法术角标列表；",
	"好运币兑换计数支持新的任务；",
	"法术图标过小时，不显示冷却计时；",
	"姓名板法术过滤调整；",
	"补充缺失的licenses；",
	"角色面板装等调整；",
	"动作条调整；",
	"技能监视列表更新；",
	"团队Debuffs结构调整；",
	"姓名板添加任务标识，默认关闭；",
	"添加萨墓的RaidDebuffs；",
	"添加萨墓的技能监视；",
	"控制台调整。",
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