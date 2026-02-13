local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新支持12.0.1；",
	"移除部分失效的功能；",
	"oUF更新；",
	"LAB更新；",
	"界面美化更新；",
	"添加内置冷却管理器和伤害统计的美化",
	"禁用内置冷却模块；",
	"禁用技能监控模块；",
	"修正信息条的错误；",
	"禁用部分通知通报功能；",
	"更新鼠标提示模块；",
	"更新Buff框体的计时方式；",
	"更新头像框体的相关标签；",
	"头像框体不再支持过量的吸收盾显示；",
	"禁用团队框体的边角指示器等监控；",
	"团队框体的监控不再接受自定义过滤；",
	"移除鼠标提示的关注信息；",
	"移除姓名板的关注指示器；",
	"移除个人资源条的技能监控；",
	"移除聊天窗口的相关缩写功能；",
	"修复专业快捷标签；",
	"添加选项以开关24小时制时间；",
	"禁用鼠标快捷标签，使用色块；",
	"修正小地图点击模块；",
	"控制台及本地文本更新。",
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
		B.CreateFS(f, 14, n..". "..t, false, "TOPLEFT", 15, -(50 + offset))
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