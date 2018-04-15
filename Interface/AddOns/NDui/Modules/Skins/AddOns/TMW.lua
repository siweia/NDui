local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")

local function ReskinTMW()
	TMW.Classes.Icon:PostHookMethod("OnNewInstance", function(self)
		B.CreateSD(self, 2, 2)
	end)

	TMW.Classes.IconModule_Texture:PostHookMethod("OnNewInstance", function(self)
		self.texture:SetTexCoord(unpack(DB.TexCoord))
	end)
end

module:LoadWithAddOn("TellMeWhen", "TMW", ReskinTMW)