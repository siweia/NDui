local B, C, L, DB = unpack(select(2, ...))
if DB.Client ~= "zhCN" then return end

local hx = {
	"更新部分技能监控；",
	"技能监控的自定义冷却模块更新；",
	"更新本地化语言；",
	"优化控制台的相关内存消耗；",
	"信息条调整；",
	"微型菜单更新；",
	"头像调整；",
	"优化内存占用；",
	"鼠标中键的快速战复功能更新；",
	"隐藏动作条的新技能高亮材质；",
	"优化自动出售垃圾的功能；",
	"启用姓名板时现在可以堆叠激励buff；",
	"优化图腾条的占用；",
	"修复部分情况下自定义冷却计时条重复刷新的问题；",
	"添加对下拉菜单污染的修复；",
	"密语时的颜色调整；",
	"聊天过滤调整；",
	"任务栏皮肤调整。",
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

NDui:EventFrame{"PLAYER_ENTERING_WORLD"}:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	if HelloWorld then return end
	if not NDuiADB["Changelog"] then NDuiADB["Changelog"] = {} end

	local old1, old2 = string.split(".", NDuiADB["Changelog"].Version or "")
	local cur1, cur2 = string.split(".", DB.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		NDuiADB["Changelog"].Version = DB.Version
	end
end)

SlashCmdList["NDUICHANGELOG"] = function()
	if not NDuiChangeLog then changelog() else NDuiChangeLog:Show() end
end
SLASH_NDUICHANGELOG1 = '/ncl'