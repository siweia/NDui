NDuiBackdropTemplateMixin = { };

local coordStart = 0.0625;
local coordEnd = 1 - coordStart;
local textureUVs = {			-- keys have to match pieceNames in nineSliceSetup table
	TopLeftCorner = { setWidth = true, setHeight = true, ULx = 0.5078125, ULy = coordStart, LLx = 0.5078125, LLy = coordEnd, URx = 0.6171875, URy = coordStart, LRx = 0.6171875, LRy = coordEnd },
	TopRightCorner = { setWidth = true, setHeight = true, ULx = 0.6328125, ULy = coordStart, LLx = 0.6328125, LLy = coordEnd, URx = 0.7421875, URy = coordStart, LRx = 0.7421875, LRy = coordEnd },
	BottomLeftCorner = { setWidth = true, setHeight = true, ULx = 0.7578125, ULy = coordStart, LLx = 0.7578125, LLy = coordEnd, URx = 0.8671875, URy = coordStart, LRx = 0.8671875, LRy = coordEnd },
	BottomRightCorner = { setWidth = true, setHeight = true, ULx = 0.8828125, ULy = coordStart, LLx = 0.8828125, LLy = coordEnd, URx = 0.9921875, URy = coordStart, LRx = 0.9921875, LRy = coordEnd },
	TopEdge = { setHeight = true, ULx = 0.2578125, ULy = "repeatX", LLx = 0.3671875, LLy = "repeatX", URx = 0.2578125, URy = coordStart, LRx = 0.3671875, LRy = coordStart },
	BottomEdge = { setHeight = true, ULx = 0.3828125, ULy = "repeatX", LLx = 0.4921875, LLy = "repeatX", URx = 0.3828125, URy = coordStart, LRx = 0.4921875, LRy = coordStart },
	LeftEdge = { setWidth = true, ULx = 0.0078125, ULy = coordStart, LLx = 0.0078125, LLy = "repeatY", URx = 0.1171875, URy = coordStart, LRx = 0.1171875, LRy = "repeatY" },
	RightEdge = { setWidth = true, ULx = 0.1328125, ULy = coordStart, LLx = 0.1328125, LLy = "repeatY", URx = 0.2421875, URy = coordStart, LRx = 0.2421875, LRy = "repeatY" },
	Center = { ULx = 0, ULy = 0, LLx = 0, LLy = "repeatY", URx = "repeatX", URy = 0, LRx = "repeatX", LRy = "repeatY" },
};
local defaultEdgeSize = 39;		-- the old default

function NDuiBackdropTemplateMixin:OnBackdropLoaded()
	if self.backdropInfo then
		-- check for invalid info
		if not self.backdropInfo.edgeFile and not self.backdropInfo.bgFile then
			self.backdropInfo = nil;
			return;
		end
		self:ApplyBackdrop();
		do
			local r, g, b = 1, 1, 1;
			if self.backdropColor then
				r, g, b = self.backdropColor:GetRGB();
			end
			local a = self.backdropColorAlpha or 1;
			self:SetBackdropColor(r, g, b, a);
		end
		do
			local r, g, b = 1, 1, 1;
			if self.backdropBorderColor then
				r, g, b = self.backdropBorderColor:GetRGB();
			end
			local a = self.backdropBorderColorAlpha or 1;
			self:SetBackdropBorderColor(r, g, b, a);
		end
		if self.backdropBorderBlendMode then
			self:SetBorderBlendMode(self.backdropBorderBlendMode);
		end
	end
end

function NDuiBackdropTemplateMixin:OnBackdropSizeChanged()
	if self.backdropInfo then
		self:SetupTextureCoordinates();
	end
end

function NDuiBackdropTemplateMixin:GetEdgeSize()
	return self.backdropInfo.edgeSize or defaultEdgeSize;
end

local function GetBackdropCoordValue(coord, pieceSetup, repeatX, repeatY)
	local value = pieceSetup[coord];
	if value == "repeatX" then
		return repeatX;
	elseif value == "repeatY" then
		return repeatY;
	else
		return value;
	end
end

local function SetupBackdropTextureCoordinates(region, pieceSetup, repeatX, repeatY)
	region:SetTexCoord(	GetBackdropCoordValue("ULx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("ULy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("LLx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("LLy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("URx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("URy", pieceSetup, repeatX, repeatY),
						GetBackdropCoordValue("LRx", pieceSetup, repeatX, repeatY), GetBackdropCoordValue("LRy", pieceSetup, repeatX, repeatY));
end

function NDuiBackdropTemplateMixin:SetupTextureCoordinates()
	local width = self:GetWidth();
	local height = self:GetHeight();
	local effectiveScale = self:GetEffectiveScale();
	local edgeSize = self:GetEdgeSize();
	local edgeRepeatX = max(0, (width / edgeSize) * effectiveScale - 2 - coordStart);
	local edgeRepeatY = max(0, (height / edgeSize) * effectiveScale - 2 - coordStart);

	for pieceName, pieceSetup in pairs(textureUVs) do
		local region = self[pieceName];
		if region then
			if pieceName == "Center" then
				local repeatX = 1;
				local repeatY = 1;
				if self.backdropInfo.tile then
					local divisor = self.backdropInfo.tileSize;
					if not divisor or divisor == 0 then
						divisor = edgeSize;
					end
					if divisor ~= 0 then
						repeatX = (width / divisor) * effectiveScale;
						repeatY = (height / divisor) * effectiveScale;
					end
				end
				SetupBackdropTextureCoordinates(region, pieceSetup, repeatX, repeatY);
			else
				SetupBackdropTextureCoordinates(region, pieceSetup, edgeRepeatX, edgeRepeatY);
			end
		end
	end
end

function NDuiBackdropTemplateMixin:SetupPieceVisuals(piece, setupInfo, pieceLayout)
	local textureInfo = textureUVs[setupInfo.pieceName];
	local tileVerts = false;
	local file;
	if setupInfo.pieceName == "Center" then
		file = self.backdropInfo.bgFile;
		tileVerts = self.backdropInfo.tile;
	else
		if self.backdropInfo.tileEdge ~= false then
			tileVerts = true;
		end
		file = self.backdropInfo.edgeFile;
	end
	piece:SetTexture(file, tileVerts, tileVerts);

	local cornerWidth = textureInfo.setWidth and self:GetEdgeSize() or 0;
	local cornerHeight = textureInfo.setHeight and self:GetEdgeSize() or 0;
	piece:SetSize(cornerWidth, cornerHeight);
end

function NDuiBackdropTemplateMixin:SetBorderBlendMode(blendMode)
	if not self.backdropInfo then
		return;
	end
	for pieceName in pairs(textureUVs) do
		local region = self[pieceName];
		if region and pieceName ~= "Center" then
			region:SetBlendMode(blendMode);
		end
	end
end

function NDuiBackdropTemplateMixin:HasBackdropInfo(backdropInfo)
	return self.backdropInfo == backdropInfo;
end

function NDuiBackdropTemplateMixin:ClearBackdrop()
	if self.backdropInfo then
		for pieceName in pairs(textureUVs) do
			local region = self[pieceName];
			if region then
				region:SetTexture(nil);
			end
		end
		self.backdropInfo = nil;
	end
end

local reusableNineSliceLayout = {
	TopLeftCorner =	{  },
	TopRightCorner =	{  },
	BottomLeftCorner =	{  },
	BottomRightCorner =	{  },
	TopEdge = {  },
	BottomEdge = {  },
	LeftEdge = {  },
	RightEdge = {  },
	Center = { layer = "BACKGROUND" },
	setupPieceVisualsFunction = BackdropTemplateMixin.SetupPieceVisuals,
};

function NDuiBackdropTemplateMixin:ApplyBackdrop()
	local x, y, x1, y1 = 0, 0, 0, 0;
	if self.backdropInfo.bgFile then
		local edgeSize = self:GetEdgeSize();
		x = -edgeSize;
		y = edgeSize;
		x1 = edgeSize;
		y1 = -edgeSize;
		local insets = self.backdropInfo.insets;
		if insets then
			x = x + (insets.left or 0);
			y = y - (insets.top or 0);
			x1 = x1 - (insets.right or 0);
			y1 = y1 + (insets.bottom or 0);
		end
	end
	local centerLayout = reusableNineSliceLayout.Center;
	centerLayout.x = x;
	centerLayout.y = y;
	centerLayout.x1 = x1;
	centerLayout.y1 = y1;

	NineSliceUtil.ApplyLayout(self, reusableNineSliceLayout);
	self:SetBackdropColor(1, 1, 1, 1);
	self:SetBackdropBorderColor(1, 1, 1, 1);
	self:SetupTextureCoordinates();
end

-- backwards compatibility API starts here
function NDuiBackdropTemplateMixin:SetBackdrop(backdropInfo)
	if backdropInfo then
		if self:HasBackdropInfo(backdropInfo) then
			return;
		end

		if not backdropInfo.edgeFile and not backdropInfo.bgFile then
			self:ClearBackdrop();
			return;
		end

		self.backdropInfo = backdropInfo;
		self:ApplyBackdrop();
	else
		self:ClearBackdrop();
	end
end

function NDuiBackdropTemplateMixin:GetBackdrop()
	if self.backdropInfo then
		-- make a copy because it will be altered to match old API output
		local backdropInfo = CopyTable(self.backdropInfo);
		-- fill in defaults
		if not backdropInfo.bgFile then
			backdropInfo.bgFile = "";
		end
		if not backdropInfo.edgeFile then
			backdropInfo.edgeFile = "";
		end
		if backdropInfo.tile == nil then
			backdropInfo.tile = false;
		end
		if backdropInfo.tileSize == nil then
			backdropInfo.tileSize = 0;
		end
		if backdropInfo.tileEdge == nil then
			backdropInfo.tileEdge = true;
		end
		if not backdropInfo.edgeSize then
			backdropInfo.edgeSize = self:GetEdgeSize();
		end
		if not backdropInfo.insets then
			backdropInfo.insets = { };
		end
		if not backdropInfo.insets.left then
			backdropInfo.insets.left = 0;
		end
		if not backdropInfo.insets.right then
			backdropInfo.insets.right = 0;
		end
		if not backdropInfo.insets.top then
			backdropInfo.insets.top = 0;
		end
		if not backdropInfo.insets.bottom then
			backdropInfo.insets.bottom = 0;
		end
		return backdropInfo;
	end
	return nil;
end

function NDuiBackdropTemplateMixin:GetBackdropColor()
	if not self.backdropInfo then
		return;
	end
	if self.Center then
		return self.Center:GetVertexColor();
	end
end

function NDuiBackdropTemplateMixin:SetBackdropColor(r, g, b, a)
	if not self.backdropInfo then
		-- Ideally this would throw an error here but the old API just failed silently
		return;
	end
	if self.Center then
		self.Center:SetVertexColor(r, g, b, a or 1);
	end
end

function NDuiBackdropTemplateMixin:GetBackdropBorderColor()
	if not self.backdropInfo then
		return
	end
	-- return the vertex color of any valid region
	for pieceName in pairs(textureUVs) do
		local region = self[pieceName];
		if region and pieceName ~= "Center" then
			return region:GetVertexColor();
		end
	end
end

function NDuiBackdropTemplateMixin:SetBackdropBorderColor(r, g, b, a)
	if not self.backdropInfo then
		-- Ideally this would throw an error here but the old API just failed silently
		return;
	end
	for pieceName in pairs(textureUVs) do
		local region = self[pieceName];
		if region and pieceName ~= "Center" then
			region:SetVertexColor(r, g, b, a or 1);
		end
	end
end