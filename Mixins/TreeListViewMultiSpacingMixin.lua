TreeListViewMultiSpacingMixin = {}

function TreeListViewMultiSpacingMixin:SetDepthSpacing(depthTable)
	self.depthSpacing = depthTable or {
		[1] = 8,
		[2] = 2,
		[3] = 1,
	}

	self.highestSpacing = 0
	self.averageSpacing = 0

	for k, v in ipairs(self.depthSpacing) do
		if(v > self.highestSpacing) then
			self.highestSpacing = v

		end

		self.averageSpacing = self.averageSpacing + v
	end

	self.averageSpacing = self.averageSpacing / 2

	--local padding = self:GetPadding()
	--self:SetPadding(padding.top, padding.bottom, padding.left, padding.right, self.highestSpacing);
end

local function CreateFrameLevelCounter(frameLevelPolicy, referenceFrameLevel, range)
	if frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Ascending then
		local frameLevel = referenceFrameLevel + 1;
		return function()
			frameLevel = frameLevel + 1;
			return frameLevel;
		end
	elseif frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Descending then
		local frameLevel = referenceFrameLevel + 1 + range;
		return function()
			frameLevel = frameLevel - 1;
			return frameLevel;
		end
	end
	return nil;
end

-- Blizzards implementation is incomplete
-- fix for lower levels having the same spacing
--[[function TreeListViewMultiSpacingMixin:LayoutInternal(layoutFunction)
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local spacing = self:GetSpacing();
	local scrollTarget = self:GetScrollTarget();
	local frameLevelCounter = CreateFrameLevelCounter(self:GetFrameLevelPolicy(), scrollTarget:GetFrameLevel(), frameCount);
	
	local offset = 0;
	local spacingTotal = 0

	--local numOfDepths = {}

	--for k, v in ipairs(self.depthSpacing) do
		--numOfDepths[k] = 0

	--end

	local padding = self:GetPadding()

	for index, frame in ipairs(frames) do
		local extent = layoutFunction(index, frame, offset, scrollTarget);
		local depthSpacing

		if(index ~= #frames) then
			local depth = frames[index + 1]:GetElementData():GetDepth()

			--numOfDepths[depth] = numOfDepths[depth] + 1
			
			depthSpacing = self.depthSpacing and self.depthSpacing[depth]

		else
			depthSpacing = 0

		end

		spacingTotal = spacingTotal + depthSpacing
		offset = offset + extent + depthSpacing;

		if frameLevelCounter then
			frame:SetFrameLevel(frameLevelCounter());
		end
	end


	local padding = self:GetPadding()
	self:SetPadding(padding.top, padding.bottom, padding.left, padding.right, spacingTotal / math.max(0, #frames - 1));
end]]

local highestTotal = 0

function TreeListViewMultiSpacingMixin:LayoutInternal(layoutFunction)
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local scrollTarget = self:GetScrollTarget();
	local frameLevelCounter = CreateFrameLevelCounter(self:GetFrameLevelPolicy(), scrollTarget:GetFrameLevel(), frameCount);
	
	local total = 0;
	local offset = 0;
	local spacingTotal = 0

	for index, frame in ipairs(frames) do
		local extent = layoutFunction(index, frame, offset, scrollTarget);

		local depthSpacing
		local depth
		
		if(index ~= #frames) then
			depth = frames[index + 1]:GetElementData():GetDepth()
			depthSpacing = self.depthSpacing and self.depthSpacing[depth]

		else
			depthSpacing = 0

		end


		spacingTotal = spacingTotal + depthSpacing
		offset = offset + extent + depthSpacing;
		total = total + extent;

		if frameLevelCounter then
			frame:SetFrameLevel(frameLevelCounter());
		end
	end

	--local spacingTotal = math.max(0, frameCount - 1) * self.highestSpacing;
	local extentTotal = total + spacingTotal;
	return extentTotal;
end