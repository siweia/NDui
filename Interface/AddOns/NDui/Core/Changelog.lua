local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local strsplit, pairs = string.split, pairs

local hx = {
	"界面美化更新；",
	"Rematch美化更新；",
	"移除对10.0.0的兼容；",
	"鼠标提示各信息模块全面更新至新的API；",
	"修正额外动作条异位的问题；",
	"更新支持至oUF 11；",
	"地图迷雾数据更新；",
	"强制显示所有小地图追踪选项；",
	"提高地图增强各元素层级；",
	"聊天复制更新；",
	"法语及俄语的本地文本更新；",
	"修复图腾栏；",
	"修正宠物及姿态条的污染；",
	"修正暴雪UI控件的移动控制；",
	"更新德鲁伊及唤魔师的技能缺失提醒；",
	"添加唤魔师的技能监控及驱散优先级等；",
	"在拾取窗口显示装备等级；",
	"动作条冷却提示调整对充能法术的通报格式；",
	"启用SexyMap时正确禁用小地图增强；",
	"修正引导法术的跳数失效的问题；",
	"修正背包鼠标提示信息的刷新；",
	"修复预创建队伍的自动邀请功能；",
	"背包材料包支持合并显示；",
	"当耐久度过低时，自动对话基维斯和里弗斯的修理功能。",
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