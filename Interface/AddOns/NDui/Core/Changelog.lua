local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local hx = {
	"法术监控列表更新；",
	"酒仙工具调整；",
	"动作条调整；",
	"AuroraClassic部分模块更新；",
	"额外任务按钮更新；",
	"小地图要塞按钮现在右键打开要塞，左键/中键打开大厅；",
	"现在CTRL点击名字可以快速邀请至公会；",
	"鼠标提示框调整；",
	"经验条调整；",
	"移除右键菜单增强；",
	"背包调整；",
	"去地图迷雾部分清理；",
	"头像数值相关调整；",
	"部分污染及内存泄漏修正。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
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
	ll:SetPoint("TOP", -50, -35)
	B.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, f)
	lr:SetPoint("TOP", 50, -35)
	B.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 12, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 20
	end
	f:SetSize(400, 60 + offset)
	local close = B.CreateButton(f, 20, 20, "X")
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if HelloWorld then return end
	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end

	local old1, old2 = string.split(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = string.split(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"