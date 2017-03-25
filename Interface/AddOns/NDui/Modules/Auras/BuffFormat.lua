local B, C, L, DB = unpack(select(2, ...))

-- Convert the Bufftimers into details
local function FormatAuraTime(seconds)
	local d, h, m, str = 0, 0, 0
	if seconds >= 86400 then
		d = seconds/86400
		seconds = seconds%86400
	end
	if seconds >= 3600 then
		h = seconds/3600
		seconds = seconds%3600
	end
	if seconds >= 60 then
		m = seconds/60
		seconds = seconds%60
	end
	if d > 0 then
		str = format("%d"..DB.MyColor.."d", d)
	elseif h > 0 then
		str = format("%d"..DB.MyColor.."h", h)
	elseif m >= 10 then
		str = format("%d"..DB.MyColor.."m", m)
	elseif m > 0 and m < 10 then
		str = format("%d:%.2d", m, seconds)
	else
		if seconds <= 5 then
			str = format("|cffff0000%.1f|r", seconds) -- red
		elseif seconds <= 10 then
			str = format("|cffffff00%.1f|r", seconds) -- yellow
		else
			str = format("%d"..DB.MyColor.."s", seconds)
		end
	end
	return str
end

hooksecurefunc("AuraButton_UpdateDuration", function(auraButton, timeLeft)
	local duration = auraButton.duration
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetFormattedText(FormatAuraTime(timeLeft))
		duration:SetVertexColor(1, 1, 1)
		duration:Show()
	else
		duration:Hide()
	end
end)