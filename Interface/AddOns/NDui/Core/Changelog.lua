local _, ns = ...
local B, C, L, DB = unpack(ns)
if DB.Client ~= "zhCN" then return end

local hx = {
	"AuroraClassic更新至1.10.8；",
	"更新技能及团本法术监控；",
	"技能监控添加高亮显示；",
	"技能监控的控制台更新；",
	"技能监控的移动模块调整；",
	"技能监控部分元素微调；",
	"技能监控自定义冷却模块逻辑优化；",
	"动作条潜在的污染修正；",
	"技能高亮调整，防止污染；",
	"装等和专精获取优化；",
	"添加选项，在按住shift时显示专精和装等；",
	"优化聊天过滤；",
	"信息条内存模块调整；",
	"信息条时间模块优化，仅在漫游周显示徽章情况；",
	"更新oUF核心；",
	"当团队框体减益优先级为6时，高亮该图标；",
	"美化战场/海岛计时条；",
	"部分API更新，优化内存控制；",
	"精简yClassColor；",
	"添加本地化的职业颜色；",
	"头像的资源条现在可以关闭。",
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
	B.CreateSD(f)
	B.CreateTex(f)
	B.CreateFS(f, 30, "NDui", true, "TOPLEFT", 10, 26)
	B.CreateFS(f, 14, DB.Version, true, "TOPLEFT", 90, 14)
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
	local close = B.CreateButton(f, 16, 16, "X")
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetScript("OnClick", function() f:Hide() end)
end

local function compareToShow(event)
	if HelloWorld then return end

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