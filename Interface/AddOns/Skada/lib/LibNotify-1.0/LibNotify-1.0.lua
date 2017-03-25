local MAJOR, MINOR = "LibNotify-1.0", "$Revision: 1 $"
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

local pairs = pairs
local unpack = unpack
local tinsert, tremove = table.insert, table.remove

local instructions = "Left-click for details, right-click to dismiss."
--local locale = GetLocale()
--Todo: translate

local storage = {}
local icons = {}
local queue = {}
local items = {}
local id = 0

local frame = nil
local content = nil
local messageframe = nil

lib.data = {
    defaulticon = "Interface\\Icons\\Inv_misc_book_02",
    notice = {
        title = {
            color = {1, 1, 1, 1},
            size = 16,
            font = [[Fonts\FRIZQT__.TTF]]
        },
        message = {
            color = {0.8, 0.8, 0.3, 1},
            size = 9,
            font = [[Fonts\FRIZQT__.TTF]]
        },
        backdrop = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = nil,
            tile = true, 
            tileSize = 16, 
            edgeSize = 16,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        },
        backdropcolor = {0, 0, 0, 0.5},
        location = {
            BOTTOM = 500,
            RIGHT = 500, 
        },
        size = {
            width = 300,
            height = 50
        }
    },
    popup = {
        title = {
            color = {1, 1, 1, 0},
            size = 22,
            font = [[Fonts\FRIZQT__.TTF]]
        },
        message = {
            color = {1, 1, 1, 0},
            size = 12,
            font = [[Fonts\FRIZQT__.TTF]]
        },
        backdrop = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, 
            tileSize = 16, 
            edgeSize = 16,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        },
        backdropcolor = {0, 0, 0, 0.5},
        size = {
            width = 600,
            height = 400
        }
    }
}

lib.mixinTargets = lib.mixinTargets or {}
local mixins = {"Notify", "NotifyOnce", "SetNotifyStorage", "SetNotifyIcon"}

local function note_to_html(note)
    local html = "<html><body>"
    for _, item in ipairs(note) do
        html = html .. "<h1>" .. item.title .. "</h1><p>" .. item.message .. "</p><br/>"
    end
    html = html .. "</body></html>"
    return html
end

local function popNotifications()
    local note = tremove(queue, 1)
    
    if not note then
        return
    end
    
    if not frame then
        local style = lib.data.notice
        frame = CreateFrame("Frame", nil, UIParent)
        frame:SetBackdrop(style.backdrop)
        frame:SetBackdropColor(style.backdropcolor)
        frame:SetSize(style.size.width, style.size.height)
        frame:SetPoint("BOTTOMRIGHT", -25, 25)
        frame:SetFrameStrata("DIALOG")
        frame:Hide()

        local titlestring = frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
        titlestring:SetTextColor(unpack(style.title.color))
        titlestring:SetFont(style.title.font, style.title.size)
        titlestring:SetWordWrap(false)
        titlestring:SetJustifyH("LEFT")
        titlestring:SetPoint("LEFT", 50, 0)
        titlestring:SetPoint("TOP", 0, -2)
        titlestring:SetHeight(40)
        
		local icon = frame:CreateTexture(nil, "OVERLAY")
		icon:SetPoint("LEFT", 4, 0)
		icon:SetPoint("CENTER", 0, 0)
		icon:SetTexture(style.defaulticon)
        icon:SetSize(style.size.height, style.size.height)
		icon:SetTexCoord(0.07,0.93,0.07,0.93);

        local messagestring = frame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
        messagestring:SetTextColor(unpack(style.message.color))
        messagestring:SetFont(style.message.font, style.message.size)
        messagestring:SetWordWrap(false)
        messagestring:SetPoint("LEFT", 50, 0)
        messagestring:SetPoint("BOTTOM", 0, 0)
        messagestring:SetHeight(20)

        local close = CreateFrame("Button", nil, frame)
        close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
        close:SetSize(25, 25)
        close:SetPoint("RIGHT", frame, "RIGHT", -2, -2)
        close:SetPoint("TOP", frame, "TOP", -2, -2)
        close:SetScript("OnClick", function(f)
            f:GetParent():Hide() 
            popNotifications()
        end)
        
        frame:EnableMouse(true)
        frame:SetScript("OnMouseDown", function(f, btn) 
            if btn == "LeftButton" then
                if not messageframe then
                    style = lib.data.popup
                    messageframe = CreateFrame("Frame", nil, UIParent)
                    messageframe:SetBackdrop(style.backdrop)
                    messageframe:SetBackdropColor(style.backdropcolor)
                    messageframe:SetSize(style.size.width, style.size.height)
                    messageframe:SetPoint("CENTER", UIParent, "CENTER")
                    messageframe:SetFrameStrata("DIALOG")
                    messageframe:Hide()
                    messageframe:EnableKeyboard(true)
                    messageframe:SetScript("OnKeyDown", function(self,key)
                        if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
                            messageframe:SetPropagateKeyboardInput(false)
                            messageframe:Hide()
                        end
                    end)
                    
                    --scrollframe 
                    local scrollframe = CreateFrame("ScrollFrame", nil, messageframe) 
                    scrollframe:SetPoint("TOPLEFT", 20, -20)
                    scrollframe:SetPoint("BOTTOMRIGHT", -30, 20) 
                    local texture = scrollframe:CreateTexture() 
                    texture:SetAllPoints() 
                    texture:SetTexture(.5,.5,.5,1) 
                    frame.scrollframe = scrollframe 

                    --scrollbar 
                    scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
                    scrollbar:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 4, -16) 
                    scrollbar:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 4, 16) 
                    scrollbar:SetMinMaxValues(1, 200) 
                    scrollbar:SetValueStep(1) 
                    scrollbar.scrollStep = 1
                    scrollbar:SetValue(0) 
                    scrollbar:SetWidth(16) 
                    scrollbar:SetScript("OnValueChanged", 
                    function (self, value) 
                        self:GetParent():SetVerticalScroll(value) 
                    end) 
                    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
                    scrollbg:SetAllPoints(scrollbar) 
                    scrollbg:SetTexture(0, 0, 0, 0.4) 
                    frame.scrollbar = scrollbar 

                    --content frame 
                    content = CreateFrame("SimpleHTML", nil, scrollframe) 
                    content:SetSize(style.size.width - 50, style.size.height - 20)
                    content:SetFont(style.message.font, style.message.size);
                    content:SetFont("h1", style.title.font, style.title.size)
                    content:SetFont("h2", style.title.font, style.title.size-4)
                    content:SetFont("h3", style.title.font, style.title.size-8)
                    scrollframe.content = content 

                    scrollframe:SetScrollChild(content)
                    
                    close = CreateFrame("Button", nil, messageframe)
                    close:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
                    close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
                    close:SetSize(50, 50)
                    close:SetPoint("RIGHT", messageframe, "RIGHT", -15, -5)
                    close:SetPoint("TOP", messageframe, "TOP", -5, -5)
                    close:SetScript("OnClick", function(f) f:GetParent():Hide() end)
                        
                end
                content:SetText(html)
                messageframe:SetPropagateKeyboardInput(true)
                messageframe:Show()
            end
            if btn == "RightButton" then
                frame:Hide()
                popNotifications()
            end
        end)
        
        frame.titlestring = titlestring
        frame.messagestring = messagestring
        frame.icon = icon
    end
    
    frame.titlestring:SetText(note[1].title)
    frame.messagestring:SetText(instructions)
    html = note_to_html(note)
    
    frame.icon:SetTexture(note[1].icon or lib.data.defaulticon)
    frame.icon:SetSize(lib.data.notice.size.height-8, lib.data.notice.size.height-8)
    frame:Show()
end

local function add_notifications(self, once, ...)
    local found = false
    if type(...) == 'table' then
        local screened = {}
        for _, item in ipairs(...) do
            if not once or not storage[self][item.id or item.title] then
                if not item.icon then
                    item.icon = icons[self]
                end
                if not item.title then
                    item.title = id
                end
                tinsert(screened, item)
                if once then
                    storage[self][item.id or item.title] = true
                end
                found = true
            end
        end
        if found then
            tinsert(queue, screened)
        end
    else
        local title, message, icon, id = ...
        if not once or not storage[self][id or title] then
            tinsert(queue, {{
                    title = title,
                    message = message,
                    icon = icon or icons[self]
            }})
            if once then
                storage[self][id or title] = true
            end
            found = true
        end
    end
    if not frame or not frame:IsShown() and found then
        popNotifications()
    end
end

-- Pass a table of notifications, or a single one as individual parameters.
-- Table notifications are shown in the notification frame as the last item - the popup shows them all.
-- If "title" is omitted on a table notification, the id is used as title.
function lib.Notify(self, ...)
    add_notifications(self, false, ...)
end

-- Pass a table of notifications, or a single one as individual parameters.
-- An extra "id" parameter is expected, to identify seen notifications. If the id is omitted, the title is used as id.
-- Table notifications are shown in the notification frame as the first item - the popup shows them all.
-- If "title" is omitted on a table notification, the id is used as title.
function lib.NotifyOnce(self, ...)
    if not storage[self] then
        error('NotifyOnce requires storage to have been set first')
    else
        add_notifications(self, true, ...)
    end
end

-- Set storage where seen notifications are stored. Only required when using "NotifyOnce".
-- This must be a table.
function lib.SetNotifyStorage(self, s)
    if type(s) ~= "table" then
        error('storage must be a table')
    else
        storage[self] = s
    end
end

-- Convenience function for setting the default icon for the addon. Icons from each notification, if present, are still preferred.
function lib.SetNotifyIcon(self, icon)
    icons[self] = icon
end

function lib:Embed(target)
  for _,name in pairs(mixins) do
    target[name] = lib[name]
  end
  lib.mixinTargets[target] = true
end

for target,_ in pairs(lib.mixinTargets) do
  lib:Embed(target)
end
