-- Theming module
Skada:AddLoadableModule("Themes", "Adds a set of standard themes to Skada. Custom themes can also be used.", function(Skada, L)
	if Skada.db.profile.modulesBlocked.Themes then return end

    local themes = {
        {
            name = "Skada default (Legion)",

            barspacing=0,
            bartexture="BantoBar",
            barfont="Accidental Presidency",
            barfontflags="",
            barfontsize=13,
            barheight=18,
            barwidth=240,
            barorientation=1,
            barcolor = {r = 0.3, g = 0.3, b = 0.8, a=1},
            barbgcolor = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            barslocked=false,
            clickthrough=false,

            classcolorbars = true,
            classcolortext = false,
            classicons = true,
            roleicons = false,
            showself = true,

            buttons = {menu = true, reset = true, report = true, mode = true, segment = true},

            title = {textcolor = {r = 0.9, g = 0.9, b = 0.9, a = 1}, height = 20, font="Accidental Presidency", fontsize=13, texture="Armory", bordercolor = {r=0,g=0,b=0,a=1}, bordertexture="None", borderthickness=2, color = {r=0.3,g=0.3,b=0.3,a=1}, fontflags = ""},
            background = {
                height=200,
                texture="Solid",
                bordercolor = {r=0,g=0,b=0,a=1}, 
                bordertexture="Blizzard Party", 
                borderthickness=2, 
                color = {r=0,g=0,b=0,a=0.4}, 
                tile = false, 
                tilesize = 0, 
            },

            strata = "LOW",
            scale = 1,

            hidden = false,
            enabletitle = true,
            titleset = true,

            display = "bar",
            snapto = true,
            scale = 1,
            version = 1,

            -- Inline exclusive
            isonnewline = false,
            isusingclasscolors = true,
            height = 30,
            width = 600,
            color = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            isusingelvuiskin = true,
            issolidbackdrop = false,
            fixedbarwidth = false,

            -- Broker exclusive
            textcolor = {r = 0.9, g = 0.9, b = 0.9},
            useframe = true
        },
            
        {
            name = "Minimalistic",

            barspacing=0,
            bartexture="Armory",
            barfont="Accidental Presidency",
            barfontflags="",
            barfontsize=12,
            barheight=16,
            barwidth=240,
            barorientation=1,
            barcolor = {r = 0.3, g = 0.3, b = 0.8, a=1},
            barbgcolor = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            barslocked=false,
            clickthrough=false,

            classcolorbars = true,
            classcolortext = false,
            classicons = true,
            roleicons = false,
            showself = true,

            buttons = {menu = true, reset = true, report = true, mode = true, segment = true},

            title = {textcolor = {r = 0.9, g = 0.9, b = 0.9, a = 1}, height = 18, font="Accidental Presidency", fontsize=12, texture="Armory", bordercolor = {r=0,g=0,b=0,a=1}, bordertexture="None", borderthickness=0, color = {r=0.6,g=0.6,b=0.8,a=1}, fontflags = ""},
            background = {
                height=195,
                texture="None",
                bordercolor = {r=0,g=0,b=0,a=1}, 
                bordertexture="Blizzard Party", 
                borderthickness=0,
                color = {r=0,g=0,b=0,a=0.4}, 
                tile = false, 
                tilesize = 0, 
            },

            strata = "LOW",
            scale = 1,

            hidden = false,
            enabletitle = true,
            titleset = true,

            display = "bar",
            snapto = true,
            scale = 1,
            version = 1,

            -- Inline exclusive
            isonnewline = false,
            isusingclasscolors = true,
            height = 30,
            width = 600,
            color = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            isusingelvuiskin = true,
            issolidbackdrop = false,
            fixedbarwidth = false,

            -- Broker exclusive
            textcolor = {r = 0.9, g = 0.9, b = 0.9},
            useframe = true
        },
            
        {
            name = "All glowy 'n stuff",

            barspacing=0,
            bartexture="LiteStep",
            barfont="ABF",
            barfontflags="",
            barfontsize=12,
            barheight=16,
            barwidth=240,
            barorientation=1,
            barcolor = {r = 0.3, g = 0.3, b = 0.8, a=1},
            barbgcolor = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            barslocked=false,
            clickthrough=false,

            classcolorbars = true,
            classcolortext = false,
            classicons = true,
            roleicons = false,
            showself = true,

            buttons = {menu = true, reset = true, report = true, mode = true, segment = true},

            title = {textcolor = {r = 0.9, g = 0.9, b = 0.9, a = 1}, height = 20, font="ABF", fontsize=12, texture="Aluminium", bordercolor = {r=0,g=0,b=0,a=1}, bordertexture="None", borderthickness=0, color = {r=0.6,g=0.6,b=0.8,a=1}, fontflags = ""},
            background = {
                height=195,
                texture="None",
                bordercolor = {r=0.9,g=0.9,b=0.5,a=0.6}, 
                bordertexture="Glow", 
                borderthickness=5,
                color = {r=0,g=0,b=0,a=0.4}, 
                tile = false, 
                tilesize = 0, 
            },

            strata = "LOW",
            scale = 1,

            hidden = false,
            enabletitle = true,
            titleset = true,

            display = "bar",
            snapto = true,
            scale = 1,
            version = 1,

            -- Inline exclusive
            isonnewline = false,
            isusingclasscolors = true,
            height = 30,
            width = 600,
            color = {r = 0.3, g = 0.3, b = 0.3, a = 0.6},
            isusingelvuiskin = true,
            issolidbackdrop = false,
            fixedbarwidth = false,

            -- Broker exclusive
            textcolor = {r = 0.9, g = 0.9, b = 0.9},
            useframe = true
        }            
    }
        
    local selectedwindow = nil
    local selectedtheme = nil
    local savewindow = nil
    local savename = nil
    local deletetheme = nil
        
    local options = {
        	type="group",
            name=L["Themes"],
            args={
                    header2 = {
                        type="header",
                        name=L["Apply theme"],
                        order=3,
                    },
                
                    applytheme = {
						type="select",
						name=L["Theme"],
						values=	function()
									local list = {}
									for i, theme in ipairs(themes) do
										list[theme.name] = theme.name
									end
                                    if Skada.db.profile.themes then
                                        for i, theme in ipairs(Skada.db.profile.themes) do
                                            list[theme.name] = theme.name
                                        end
                                    end
									return list
								end,
						get=function() return selectedtheme end,
						set=function(i, name) selectedtheme = name end,
						order=3.1,
					},
                    applywindow = {
						type="select",
						name=L["Window"],
						values=	function()
                            local list = {}
                            for i, win in ipairs(Skada:GetWindows()) do
                                list[win.db.name] = win.db.name
                            end
                            return list
                        end,
						get=function() return selectedwindow end,
						set=function(i, name) selectedwindow = name end,
						order=3.2,
					},
					applybutton = {
						type="execute",
						name=L["Apply"],
						func=function()
                            if selectedwindow and selectedtheme then
                                local thetheme = nil
								for i, theme in ipairs(themes) do
                                    if theme.name == selectedtheme then thetheme = theme end
                                end
                                if Skada.db.profile.themes then
                                    for i, theme in ipairs(Skada.db.profile.themes) do
                                        if theme.name == selectedtheme then thetheme = theme end
                                    end
                                end
                            
                                if thetheme then
                                    for i, win in ipairs(Skada:GetWindows()) do
                                        if win.db.name == selectedwindow then
                                            Skada:tcopy(win.db, thetheme, {"name", "modeincombat", "display", "set", "mode", "wipemode", "returnaftercombat"})
                                            Skada:ApplySettings()
                                            Skada:Print(L["Theme applied!"])
                                        end
                                    end
                                end
                            end
                        end,
						order=3.3,
					},
                
                    header3 = {
                        type="header",
                        name=L["Save theme"],
                        order=4,
                    },
                
                    savewindow = {
						type="select",
						name=L["Window"],
						values=	function()
                            local list = {}
                            for i, win in ipairs(Skada:GetWindows()) do
                                list[win.db.name] = win.db.name
                            end
                            return list
                        end,
						get=function() return savewindow end,
						set=function(i, name) savewindow = name end,
						order=4.1,
					},
					savenametext = {
						type="input",
						name=L["Name"],
                        desc=L["Name of your new theme."],
                        get=function() return savename end,
                        set=function(i, val) savename = val end,
						order=4.2,
					},
					savebutton = {
						type="execute",
						name=L["Save"],
						func=function()
                            for i, win in ipairs(Skada:GetWindows()) do
                                if win.db.name == savewindow then
                                    Skada.db.profile.themes = Skada.db.profile.themes or {}
                                    local theme = {}
                                    Skada:tcopy(theme, win.db)
                                    theme.name = savename
                                    table.insert(Skada.db.profile.themes, theme)
                                end
                            end
                        end,
						order=4.3,
					},
                
                    header4 = {
                        type="header",
                        name=L["Delete theme"],
                        order=5,
                    },
                
                    deltheme = {
						type="select",
						name=L["Theme"],
						values=	function()
                            local list = {}
                            if Skada.db.profile.themes then
                                for i, theme in ipairs(Skada.db.profile.themes) do
                                    list[theme.name] = theme.name
                                end
                            end
                            return list
                        end,
						get=function() return deletetheme end,
						set=function(i, name) deletetheme = name end,
						order=5.1,
					},
                
					deletebutton = {
						type="execute",
						name=L["Delete"],
						func=function()
                            if Skada.db.profile.themes then
                                for i, theme in ipairs(Skada.db.profile.themes) do
                                    if theme.name == deletetheme then
                                        table.remove(Skada.db.profile.themes, i)
                                    end
                                end
                            end
                        end,
						order=5.2
					},                
                
            }
    }
    
    Skada.options.args['Themes'] = options
        
end)
