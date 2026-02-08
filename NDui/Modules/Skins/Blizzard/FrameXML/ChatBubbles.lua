local _, ns = ...
local B, C, L, DB = unpack(ns)

local pairs, GetCVarBool = pairs, GetCVarBool
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
	if chatbubble.styled then return end

	local frame = chatbubble:GetChildren()
	if frame and not frame:IsForbidden() then
		local bg = B.SetBD(frame)
		bg:SetScale(UIParent:GetEffectiveScale())
		bg:SetInside(frame, 6, 6)

		frame:DisableDrawLayer("BORDER")
		frame.Tail:SetAlpha(0)
	end

	chatbubble.styled = true
end

tinsert(C.defaultThemes, function()
	if not C.db["Skins"]["BlizzardSkins"] then return end

	local events = {
		CHAT_MSG_SAY = "chatBubbles",
		CHAT_MSG_YELL = "chatBubbles",
		CHAT_MSG_MONSTER_SAY = "chatBubbles",
		CHAT_MSG_MONSTER_YELL = "chatBubbles",
		CHAT_MSG_PARTY = "chatBubblesParty",
		CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
		CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
	}

	local bubbleHook = CreateFrame("Frame")
	for event in next, events do
		bubbleHook:RegisterEvent(event)
	end
	bubbleHook:SetScript("OnEvent", function(self, event)
		if GetCVarBool(events[event]) then
			self.elapsed = 0
			self:Show()
		end
	end)

	bubbleHook:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > .1 then
			for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
				reskinChatBubble(chatbubble)
			end
			self:Hide()
		end
	end)
	bubbleHook:Hide()
end)