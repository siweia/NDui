﻿local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Chat")

function module:ChannelRename()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local f = _G["ChatFrame"..i]
			local am = f.AddMessage
			f.AddMessage = function(frame, text, ...)
				if text:find(INTERFACE_ACTION_BLOCKED) and not DB.isDeveloper then return end

				local r, g, b = ...
				if text:find(L["Tell"].." |Hplayer.+%]") then r, g, b = .6, .6, .6 end
				if NDuiDB["Chat"]["Oldname"] then
					text = text:gsub("|h%[(%d+)%. 大脚世界频道%]|h", "|h%[%1%. 世界%]|h")
					text = text:gsub("|h%[(%d+)%. 大腳世界頻道%]|h", "|h%[%1%. 世界%]|h")
					return am(frame, text, r, g, b)
				else
					return am(frame, text:gsub("|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
				end
			end
		end
	end

	--online/offline info
	ERR_FRIEND_ONLINE_SS = ERR_FRIEND_ONLINE_SS:gsub("%]%|h", "]|h|cff00c957")
	ERR_FRIEND_OFFLINE_S = ERR_FRIEND_OFFLINE_S:gsub("%%s", "%%s|cffff7f50")

	if NDuiDB["Chat"]["Oldname"] then return end
	--guild
	CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
	CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s "

	--raid
	CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
	CHAT_RAID_WARNING_GET = "[RW] %s "
	CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

	--party
	CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
	CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[PL]|h %s "
	CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[PG]|h %s "

	--instance
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE|h[I]|h %s "
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE|h[IL]|h %s "

	--whisper  
	CHAT_WHISPER_INFORM_GET = L["Tell"].." %s "
	CHAT_WHISPER_GET = L["From"].." %s "
	CHAT_BN_WHISPER_INFORM_GET = L["Tell"].." %s "
	CHAT_BN_WHISPER_GET = L["From"].." %s "

	--say / yell
	CHAT_SAY_GET = "%s "
	CHAT_YELL_GET = "%s "

	--flags
	CHAT_FLAG_AFK = "[AFK] "
	CHAT_FLAG_DND = "[DND] "
	CHAT_FLAG_GM = "[GM] "
end