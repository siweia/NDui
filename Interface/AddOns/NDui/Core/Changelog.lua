local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"更新部分技能监控；",
	"姓名板自定义过滤更新；",
	"信息条更新，监控噬渊折磨者的击杀情况；",
	"调整当AngryKeystones启用时相关元素的位置；",
	"邮箱联系人优化，列表现在以服务器排序；",
	"DBM及Rematch美化更新；",
	"界面美化部分模块更新；",
	"心能选择面板现在可以通过命令移动；",
	"背包添加选项以关注宠物垃圾货币；",
	"小地图收回站的排序调整；",
	"鼠标提示添加目标史诗钥石评分；",
	"鼠标提示添加统御碎片等级显示；",
	"修正国服启用语言过滤器后好友无法交互的问题；",
	"施法条支持单独关闭；",
	"优化聊天快捷标签；",
	"大部分框体现在可以在战斗中打开；",
	"拆分打断和驱散的通报选项；",
	"修正团队工具的MRT药水检查功能；",
	"控制台及本地文本更新。",
}

local f
local function changelog()
	if f then f:Show() return end

	f = CreateFrame("Frame", "NDuiChangeLog", UIParent)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	B.CreateMF(f)
	B.SetBD(f)
	B.CreateFS(f, 18, DB.Version.." "..L["Changelog"], true, "TOP", 0, -10)
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