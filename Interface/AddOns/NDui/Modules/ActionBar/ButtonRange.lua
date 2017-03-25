local B, C, L, DB = unpack(select(2, ...))

hooksecurefunc("ActionButton_OnUpdate", function(self, elapsed)
	if self.rangeTimer == TOOLTIP_UPDATE_TIME and self.action then
		local range = false
		if IsActionInRange(self.action) == false then
			self.icon:SetVertexColor(.9, .1, .1)
			self.NormalTexture:SetVertexColor(.9, .1, .1)
			range = true
		end

		if self.range ~= range and range == false then
			ActionButton_UpdateUsable(self)
		end

		self.range = range
	end
end)