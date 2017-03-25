local L = LibStub("AceLocale-3.0"):GetLocale("Skada", false)
local Skada = Skada
local name = L["Inline bar display"]

local mod = Skada:NewModule(name)
local mybars = {}
local barlibrary = {
    bars = {},
    nextuuid = 1
}
local leftmargin = 40
local ttactive = false

local libwindow = LibStub("LibWindow-1.1")
local media = LibStub("LibSharedMedia-3.0")

mod.name = name
mod.description = L["Inline display is a horizontal window style."]
Skada:AddDisplaySystem("inline", mod)

function serial(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep("·", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serial(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function mod:OnInitialize()

end

local function BarLeave(bar)
    local win, id, label = bar.win, bar.id, bar.text
    if ttactive then
        GameTooltip:Hide()
        ttactive = false
    end
end

local function showmode(win, id, label, mode)
    -- Add current mode to window traversal history.
    if win.selectedmode then
        tinsert(win.history, win.selectedmode)
    end
    -- Call the Enter function on the mode.
    if mode.Enter then
        mode:Enter(win, id, label)
    end
    -- Display mode.
    win:DisplayMode(mode)
end

local function BarClick(win, bar, button)
    local id, label =  bar.valueid, bar.valuetext
    local click1 = win.metadata.click1
    local click2 = win.metadata.click2
    local click3 = win.metadata.click3

    if button == "RightButton" and IsShiftKeyDown() then
        Skada:OpenMenu(win)
    elseif win.metadata.click then
        win.metadata.click(win, id, label, button)
    elseif button == "RightButton" then
        win:RightClick()
    elseif click2 and IsShiftKeyDown() then
        showmode(win, id, label, click2)
    elseif click3 and IsControlKeyDown() then
        showmode(win, id, label, click3)
    elseif click1 then
        showmode(win, id, label, click1)
    end
end

function mod:Create(window, isnew)
    if not window.frame then
        window.frame = CreateFrame("Frame", window.db.name.."InlineFrame", UIParent)
        window.frame.win = window
        window.frame:SetFrameLevel(5)
        if window.db.height==15 then window.db.height = 23 end--TODO: Fix dirty hack
        window.frame:SetHeight(window.db.height)
        window.frame:SetWidth(window.db.width or GetScreenWidth())
        window.frame:ClearAllPoints()
        window.frame:SetPoint("BOTTOM", -1)
        window.frame:SetPoint("LEFT", -1)
        if window.db.background.color.a==51/255 then window.db.background.color = {r=255, b=250/255, g=250/255, a=1 } end
    end

    window.frame:EnableMouse()
    window.frame:SetScript("OnMouseDown", function(frame, button)
        if button == "RightButton" then
            window:RightClick()
        end
    end)

    -- Register with LibWindow-1.1.
    libwindow.RegisterConfig(window.frame, window.db)

    -- Restore window position.
    if isnew then
        libwindow.SavePosition(window.frame)
    else
        libwindow.RestorePosition(window.frame)
    end
        
    window.frame:EnableMouse(true)
    window.frame:SetMovable(true)
    window.frame:RegisterForDrag("LeftButton")
    window.frame:SetScript("OnDragStart", function(frame)
        if not window.db.barslocked then
            GameTooltip:Hide()
            frame.isDragging = true
            frame:StartMoving()
        end
    end)
    window.frame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        frame.isDragging = false
        libwindow.SavePosition(frame)
    end)        

    local titlebg = CreateFrame("Frame", "InlineTitleBackground", window.frame)
    local title = window.frame:CreateFontString("frameTitle", 6)
    title:SetTextColor(self:GetFontColor(window.db))
    --window.frame.fstitle:SetTextColor(255,255,255,1)
    title:SetFont(self:GetFont(window.db))
    title:SetText(window.metadata.title or "Skada")
    title:SetWordWrap(false)
    title:SetJustifyH("LEFT")
    title:SetPoint("LEFT", leftmargin, -1)
    title:SetPoint("CENTER", 0, 0)
    title:SetHeight(window.db.height or 23)
    window.frame.fstitle = title
    window.frame.titlebg = titlebg

    titlebg:SetAllPoints(title)
    titlebg:EnableMouse(true)
    titlebg:SetScript("OnMouseDown", function(frame, button)
        if button == "RightButton" then
            Skada:SegmentMenu(window)
        end
        if button == "LeftButton" then
            Skada:ModeMenu(window)
        end
    end)

    local skadamenubuttonbackdrop = {
        bgFile = "Interface\\Buttons\\UI-OptionsButton",
        edgeFile = "Interface\\Buttons\\UI-OptionsButton",
        bgFile = nil,
        edgeFile = nil,
        tile = true,
        tileSize = 12,
        edgeSize = 0,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    }

    local menu = CreateFrame("Button", "InlineFrameMenuButton", window.frame)
    menu:ClearAllPoints()
    menu:SetWidth(12)
    menu:SetHeight(12)
    menu:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    menu:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", 1.0)
    menu:SetAlpha(0.5)
    menu:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    menu:SetBackdropColor(window.db.title.textcolor.r,window.db.title.textcolor.g,window.db.title.textcolor.b,window.db.title.textcolor.a)
    menu:SetPoint("BOTTOMLEFT", window.frame, "BOTTOMLEFT", 6, window.db.height/2-8)
    menu:SetFrameLevel(9)
    menu:SetPoint("CENTER")
    menu:SetBackdrop(skadamenubuttonbackdrop)
    menu:SetScript("OnClick", function()
        Skada:OpenMenu(window)
    end)
    window.frame.menu = menu
    window.frame.skadamenubutton = title

    window.frame.barstartx = leftmargin + window.frame.fstitle:GetStringWidth()

    window.frame.win = window
    window.frame:EnableMouse(true)

    --create 20 barframes
    local temp = 25
    repeat
        local bar = barlibrary:CreateBar(nil, window)
        barlibrary.bars[temp] = bar
        temp = temp - 1
    until(temp < 1)
    self:Update(window)
end

function mod:Destroy(win)
    win.frame:Hide()
    win.frame = nil
end

function mod:Wipe(win) end

function mod:SetTitle(win, title)
    win.frame.fstitle:SetText(title)
    win.frame.barstartx = leftmargin + win.frame.fstitle:GetStringWidth() + 20
end

function barlibrary:CreateBar(uuid, win)
    local bar = {}
    bar.uuid = uuid or self.nextuuid
    bar.inuse = false
    bar.value = 0
    bar.win = win

    bar.bg = CreateFrame("Frame", "bg"..bar.uuid, win.frame)
    bar.label = bar.bg:CreateFontString("label"..bar.uuid)
    bar.label:SetFont(mod:GetFont(win.db))
    bar.label:SetTextColor(mod:GetFontColor(win.db))
    bar.label:SetJustifyH("LEFT")
    bar.label:SetJustifyV("MIDDLE")
    bar.bg:EnableMouse(true)
    bar.bg:SetScript("OnMouseDown", function(frame, button)
        BarClick(win, bar, button)
    end)
    bar.bg:SetScript("OnEnter", function(frame, button)
        ttactive = true
		Skada:SetTooltipPosition(GameTooltip, win.frame)
        Skada:ShowTooltip(win, bar.valueid, bar.valuetext)
    end)
    bar.bg:SetScript("OnLeave", function(frame, button)
        if ttactive then
            GameTooltip:Hide()
            ttactive = false
        end
    end)

    if uuid then
        self.nextuuid = self.nextuuid + 1
    end
    return bar
end

function barlibrary:Deposit (_bar)
    --strip the bar of variables
    _bar.inuse = false
    _bar.bg:Hide()
    _bar.value = 0
    _bar.label:Hide()
    --place it at the front of the queue
    table.insert(barlibrary.bars, 1, _bar)
    --print("Depositing bar.uuid", _bar.uuid)
end

function barlibrary:Withdraw (win)--TODO: also pass parent and assign parent
    local db = win.db

    if #barlibrary.bars < 2 then
        --if barlibrary is empty, create a new bar to replace this bar
        local replacement = {}
        local uuid = 1
        if #barlibrary.bars==0 then
            --No data
            uuid = 1
        elseif #barlibrary.bars < 2 then
            uuid = barlibrary.bars[#barlibrary.bars].uuid + 1
        else
            uuid = 1
            print("|c0033ff99SkadaInline|r: THIS SHOULD NEVER HAPPEN")
        end
        replacement = self:CreateBar(uuid, win)

        --add the replacement bar to the end of the bar library
        table.insert(barlibrary.bars, replacement)
    end
    --mark the bar you will give away as in use & give it a barid
    barlibrary.bars[1].inuse = false
    barlibrary.bars[1].value = 0
    barlibrary.bars[1].label:SetJustifyH("LEFT")
    --barlibrary.bars[1].label:SetJustifyV("CENTER")
    mod:ApplySettings(win)
    return table.remove(barlibrary.bars, 1)
end

function mod:RecycleBar(_bar)
    _bar.value = 0
    --hide stuff
    _bar.label:Hide()
    _bar.bg:Hide()
    barlibrary:Deposit(_bar)
end

function mod:GetBar(win)
    return barlibrary:Withdraw(win)
end

function mod:UpdateBar(bar, bardata, db)
    local label = bardata.label
    if db.isusingclasscolors then
        if bardata.class then
            label = "|c"
            label = label..RAID_CLASS_COLORS[bardata.class].colorStr
            label = label..bardata.label
            label = label.."|r"
        end
    else
        label = bardata.label
    end
    if bardata.valuetext then
        if db.isonnewline and db.barfontsize*2 < db.height then label = label.."\n" else label = label.." - " end
        label = label..bardata.valuetext
    end
    bar.label:SetFont(mod:GetFont(db))
    bar.label:SetText(label)
    bar.label:SetTextColor(mod:GetFontColor(db))
    bar.value = bardata.value
    bar.class = bardata.class

    bar.valueid = bardata.id
    bar.valuetext = bardata.label

    return bar
end

function mod:Update(win)
    wd = win.dataset

    --purge nil values from dataset
    for i=#win.dataset, 1, -1 do
        if win.dataset[i].label==nil then
            table.remove(win.dataset, i)
        end
    end

    --TODO: Only if the number of bars changes
    --delete any current bars
    local i = #mybars
    while i > 0 do
       mod:RecycleBar(table.remove(mybars, i))
        i = i - 1
    end

    for k,bardata in pairs(win.dataset) do
        if bardata.id then
            --Update a fresh bar
            local _bar = mod:GetBar(win)
            table.insert(mybars, mod:UpdateBar(_bar, bardata, win.db))
        end
    end

    --sort bars
    table.sort(mybars, function (bar1, bar2)
            if not bar1 or bar1.value==nil then
                return false
            elseif not bar2 or bar2.value==nil then
                return true
            else
                return bar1.value > bar2.value
            end
    end)

    -- TODO: fixed bars

    local yoffset = (win.db.height - win.db.barfontsize) / 2
    local left = win.frame.barstartx + 40
    for key, bar in pairs(mybars) do
        --set bar positions
        --TODO
        --bar.texture:SetTexture(255, 0, 0, 1.00)

        bar.bg:SetFrameLevel(9)
        bar.bg:SetHeight(win.db.height)
        bar.bg:SetPoint("BOTTOMLEFT", win.frame, "BOTTOMLEFT", left, 0)
        bar.label:SetHeight(win.db.height)
        bar.label:SetPoint("BOTTOMLEFT", win.frame, "BOTTOMLEFT", left, 0)
        bar.bg:SetWidth(bar.label:GetStringWidth())
        --increment left value
        if win.db.fixedbarwidth then
            left = left + win.db.barwidth
        else
            left = left + bar.label:GetStringWidth()
            left = left + 15
        end
        --show bar
        if (left + win.frame:GetLeft()) < win.frame:GetRight() then
            bar.bg:Show()
            bar.label:Show()
        else
            bar.bg:Hide()
            bar.label:Hide()
        end
    end
end

function mod:Show(win)
    win.frame:Show()
end

function mod:Hide(win)
    win.frame:Hide()
end

function mod:IsShown(win)
    return win.frame:IsShown()
end

function mod:OnMouseWheel(win, frame, direction) end

function mod:CreateBar(win, name, label, maxValue, icon, o)
    --print("mod:CreateBar():TODO")
    local bar = {}
    bar.win = win


    return bar
end

function mod:GetFont(db)
    if db.isusingelvuiskin and ElvUI then
        if ElvUI then return ElvUI[1]["media"].normFont, db.barfontsize, nil else return nil end
    else
        return media:Fetch('font', db.barfont), db.barfontsize, db.barfontflags
    end
end

function mod:GetFontColor(db)
    if db.isusingelvuiskin and ElvUI then
        return 255,255,255,1
    else
        return  db.title.textcolor.r,db.title.textcolor.g,db.title.textcolor.b,db.title.textcolor.a
    end
end

function mod:ApplySettings(win)
    local f = win.frame
    local p = win.db

    --
    --bars
    --
    f:SetHeight(p.height)
    f:SetWidth(win.db.width or GetScreenWidth())
    f.fstitle:SetTextColor(self:GetFontColor(p))
    f.fstitle:SetFont(self:GetFont(p))
    for k,bar in pairs(mybars) do
        --bar.label:SetFont(p.barfont,p.barfontsize,p.barfontflags )
        bar.label:SetFont(self:GetFont(p))
        bar.label:SetTextColor(self:GetFontColor(p))

        bar.bg:EnableMouse(not p.clickthrough)
    end

    f.menu:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 6, win.db.height/2-8)

    f:EnableMouse(not p.clickthrough)
    f:SetScale(p.scale)

    --
    --ElvUI
    --
    if p.isusingelvuiskin and ElvUI then
        --bars
        f:SetHeight(p.height)
        f.fstitle:SetTextColor(255,255,255,1)        --local _r, _g, _b = unpack(ElvUI[1]["media"].rgbvaluecolor)
        f.fstitle:SetFont(ElvUI[1]["media"].normFont, p.barfontsize, nil)
        for k,bar in pairs(mybars) do
            bar.label:SetFont(ElvUI[1]["media"].normFont, p.barfontsize, nil)
            bar.label:SetTextColor(255,255,255,1)
        end

        --background
        local fbackdrop = {}
        local borderR,borderG,borderB = unpack(ElvUI[1]["media"].bordercolor)
        local backdropR, backdropG, backdropB = unpack(ElvUI[1]["media"].backdropcolor)
        local backdropA = 0
        if p.issolidbackdrop then backdropA = 1.0 else backdropA = 0.8 end
        local resolution =  ({GetScreenResolutions()})[GetCurrentResolution()]
        local mult = 768/string.match(resolution, "%d+x(%d+)")/(max(0.64, min(1.15, 768/GetScreenHeight() or UIParent:GetScale())))

        fbackdrop.bgFile = ElvUI[1]["media"].blankTex
        fbackdrop.edgeFile = ElvUI[1]["media"].blankTex
        fbackdrop.tile = false
        fbackdrop.tileSize = 0
        fbackdrop.edgeSize = mult
        fbackdrop.insets = { left = 0, right = 0, top = 0, bottom = 0 }
        f:SetBackdrop(fbackdrop)
        f:SetBackdropColor(backdropR, backdropG, backdropB, backdropA)
        f:SetBackdropBorderColor(borderR, borderG, borderB, 1.0)

    else
        --
        --background
        --
        local fbackdrop = {}
        fbackdrop.bgFile = media:Fetch("background", p.background.texture)
        fbackdrop.tile = p.background.tile
        fbackdrop.tileSize = p.background.tilesize
        f:SetBackdrop(fbackdrop)
        f:SetBackdropColor(p.background.color.r,p.background.color.g,p.background.color.b,p.background.color.a)
        f:SetFrameStrata(p.strata)

        Skada:ApplyBorder(f, p.background.bordertexture, p.background.bordercolor, p.background.borderthickness)
    end
end

function mod:AddDisplayOptions(win, options)
    local db = win.db
    options.baroptions = {
        type = "group",
        name = "Text",
        order = 3,
        args = {
            isonnewline = {
                type = 'toggle',
                name = "Put values on new line.",
                desc = "New line:\nExac\n30.71M (102.1K)\n\nDivider:\nExac - 30.71M (102.7K)",
                get = function() return db.isonnewline end,
                set = function(win,key)
                    db.isonnewline = key
                    Skada:ApplySettings()
                end,
                order=0.0,
            },
            isusingclasscolors = {
                type = 'toggle',
                name = "Use class colors",
                desc = "Class colors:\n|cFFF58CBAExac|r - 30.71M (102.7K)\nWithout:\nExac - 30.71M (102.7K)",
                get = function() return db.isusingclasscolors end,
                set = function(win,key)
                    db.isusingclasscolors = key
                    Skada:ApplySettings()
                end,
                order=0.05,
            },
            barwidth = {
                type = 'range',
                name = "Width",
                desc = "Width of bars. This only applies if the 'Fixed bar width' option is used.",
                min=100,
                max=300,
                step=1.0,
                get = function()
                    return db.barwidth
                end,
                set = function(win,key)
                    db.barwidth = key
                    Skada:ApplySettings()
                end,
                order=2,
            },
            color = {
                type="color",
                name="Font Color",
                desc="Font Color. \nClick 'class color' to begin.",
                hasAlpha=true,
                get=function()
                    local c = db.title.textcolor
                    return c.r, c.g, c.b, c.a
                end,
                set=function(win, r, g, b, a)
                    db.title.textcolor = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or 1.0 }
                    Skada:ApplySettings()
                end,
                order=3.1,
            },
            barfont = {
                type = 'select',
                dialogControl = 'LSM30_Font',
                name = L["Bar font"],
                desc = L["The font used by all bars."],
                values = AceGUIWidgetLSMlists.font,
                get = function() return db.barfont end,
                set = function(win,key)
                    db.barfont = key
                    Skada:ApplySettings()
                end,
                order=1,
            },

            barfontsize = {
                type="range",
                name=L["Bar font size"],
                desc=L["The font size of all bars."],
                min=7,
                max=40,
                step=1,
                get=function() return db.barfontsize end,
                set=function(win, size)
                    db.barfontsize = size
                    Skada:ApplySettings()
                end,
                order=2,
            },

            barfontflags = {
                type = 'select',
                name = L["Font flags"],
                desc = L["Sets the font flags."],
                values = {[""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick outline"], ["MONOCHROME"] = L["Monochrome"], ["OUTLINEMONOCHROME"] = L["Outlined monochrome"]},
                get = function() return db.barfontflags end,
                set = function(win,key)
                    db.barfontflags = key
                    Skada:ApplySettings()
                end,
                order=3,
            },

            clickthrough = {
                    type="toggle",
                    name=L["Clickthrough"],
                    desc=L["Disables mouse clicks on bars."],
                    order=20,
                    get=function() return db.clickthrough end,
                    set=function()
                            db.clickthrough = not db.clickthrough
                            Skada:ApplySettings()
                        end,
            },

            fixedbarwidth = {
                    type="toggle",
                    name=L["Fixed bar width"],
                    desc=L["If checked, bar width is fixed. Otherwise, bar width depends on the text width."],
                    order=21,
                    get=function() return db.fixedbarwidth end,
                    set=function()
                            db.fixedbarwidth = not db.fixedbarwidth
                            Skada:ApplySettings()
                        end,
            },

        }
    }

    options.elvuioptions = {
        type = "group",
        name = "ElvUI",
        order = 4,
        args = {
            isusingelvuiskin = {
                type = 'toggle',
                name = "Use ElvUI skin if avaliable.",
                desc = "Check this to use ElvUI skin instead. \nDefault: checked",
                get = function() return db.isusingelvuiskin end,
                set = function(win,key)
                    db.isusingelvuiskin = key
                    Skada:ApplySettings()
                end,
                order=0.1,
            },
            issolidbackdrop = {
                type = 'toggle',
                name = "Use solid background.",
                desc = "Un-check this for an opaque background.",
                get = function() return db.issolidbackdrop end,
                set = function(win,key)
                    db.issolidbackdrop = key
                    Skada:ApplySettings()
                end,
                order=1.0,
            },
        },
    }
        
    options.frameoptions = Skada:FrameSettings(db, true)
end
