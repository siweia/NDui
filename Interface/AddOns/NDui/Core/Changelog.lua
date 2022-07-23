local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"修正法术护甲信息；",
	"默认界面美化更新；",
	"重置并重制了团队框体点击施法，支持更多组合键；",
	"更新信息条天赋模块；",
	"更新oUF核心；",
	"合并背包剩余空间时也合并灵魂袋及弹药/箭袋；",
	"邮箱调整；",
	"更新LibHealComm；",
	"WLK: 背包整理更新支持新的灵魂袋及弹药/箭袋；",
	"WLK: 更新及修复默认框体的美化；",
	"WLK: 替换组队工具的职责相关信息；",
	"WLK: 添加选项以开关日历按钮；",
	"WLK: 优化装备方案管理，右键双击可直接卸下所有装备；",
	"WLK: 自动选择与你天赋同名的装备方案；",
	"WLK: 在装备选择页显示装等；",
	"WLK: 调整玩家属性面板；",
	"WLK: 守护条支持龙鹰守护；",
	"WLK: 添加新版本的相关副本监控位。",
}

local f
local function changelog()
	if f then f:Show() return end

	local majorVersion = gsub(DB.Version, "%.%d+$", ".0")

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, majorVersion.." "..L["Changelog"], true, "TOP", 0, -10)
	B.CreateWatermark(f)

	local ll = B.SetGradient(f, "H", .7, .7, .7, 0, .5, 100, C.mult)
	ll:SetPoint("TOP", -50, -35)
	local lr = B.SetGradient(f, "H", .7, .7, .7, .5, 0, 100, C.mult)
	lr:SetPoint("TOP", 50, -35)

	local offset = 0
	for n, t in pairs(hx) do
		B.CreateFS(f, 14, n..": "..t, false, "TOPLEFT", 15, -(50 + offset))
		offset = offset + 24
	end
	f:SetSize(480, 60 + offset)
	local close = B.CreateButton(f, 16, 16, true, DB.closeTex)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if NDui_Tutorial then return end

	local old1, old2 = strsplit(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = strsplit(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end

	B:UnregisterEvent(event, compareToShow)
end
B:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

SlashCmdList["NDUICHANGELOG"] = changelog
SLASH_NDUICHANGELOG1 = "/ncl"