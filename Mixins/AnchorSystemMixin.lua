AnchorSystemMixin = {}

local function findNextNumber(baseNumber, array)
    local closest, index = math.huge, -1

    for _, otherNumber in pairs(array) do
        if math.abs(baseNumber - otherNumber) < math.abs(baseNumber - closest) then
            closest = otherNumber
            index = _
        end
    end

    return closest, index - 1
end


function AnchorSystemMixin:AddMiddlePoints()
 -- always add points to the middle and go out from there
 -- set ids accordingly
end

function AnchorSystemMixin:CreateLeftPoint()
    local frame3 = CreateFrame("Frame", nil, self)
    frame3:SetHeight(1)
    frame3:SetPoint("TOPLEFT")

    tinsert(self.anchorPoints, {point = {frame3:GetPoint(1)}, depth = 0})
end

function AnchorSystemMixin:CreateRightPoint()
    local frame3 = CreateFrame("Frame", nil, self)
    frame3:SetHeight(1)
    frame3:SetPoint("TOPRIGHT")

    tinsert(self.anchorPoints, {point = {frame3:GetPoint(1)}, depth = 0})
        
end

function AnchorSystemMixin:CreateMiddlePoint()
    local frame3 = CreateFrame("Frame", nil, self)
    frame3:SetHeight(1)
    frame3:SetPoint("TOP")

    tinsert(self.anchorPoints, {point = {frame3:GetPoint(1)}, depth = 0})

end

function AnchorSystemMixin:CreateAnchorPoints(depth, maxDepth, nextParent)
    local frame1 = CreateFrame("Frame", nil, self)
    frame1:SetHeight(1)
    frame1:SetPoint("TOPLEFT", nextParent or self, "TOPLEFT")
    frame1:SetPoint("TOPRIGHT", nextParent or self, "TOP")

    local frame2 = CreateFrame("Frame", nil, self)
    frame2:SetHeight(1)
    frame2:SetPoint("TOPLEFT", nextParent or self, "TOP")
    frame2:SetPoint("TOPRIGHT", nextParent or self, "TOPRIGHT")

    if(depth < maxDepth) then
        self:CreateAnchorFrames(depth + 1, maxDepth, frame1)

        if(not nextParent) then
            self:CreateMiddlePoint()

        end

        self:CreateAnchorFrames(depth + 1, maxDepth, frame2)

    else
        tinsert(self.anchorPoints, {point = {frame1:GetPoint(1)}, depth = depth})

        if(not nextParent) then
            self:CreateMiddlePoint()
            
        end

        tinsert(self.anchorPoints, {point = {frame2:GetPoint(2)}, depth = depth})

    end

end

function AnchorSystemMixin:CreateAnchorFrames(depth, maxDepth, nextParent)
    local frame1 = CreateFrame("Frame", nil, self)
    frame1:SetHeight(1)
    frame1:SetPoint("TOPLEFT", nextParent or self, "TOPLEFT")
    frame1:SetPoint("TOPRIGHT", nextParent or self, "TOP")

    local frame2 = CreateFrame("Frame", nil, self)
    frame2:SetHeight(1)
    frame2:SetPoint("TOPLEFT", nextParent or self, "TOP")
    frame2:SetPoint("TOPRIGHT", nextParent or self, "TOPRIGHT")

    if(depth < maxDepth) then
        self:CreateAnchorFrames(depth + 1, maxDepth, frame1)
        self:CreateAnchorFrames(depth + 1, maxDepth, frame2)

    else
        tinsert(self.anchorFrames, {frame = frame1, depth = depth})
        tinsert(self.anchorFrames, {frame = frame2, depth = depth})

    end
end

function AnchorSystemMixin:OnLoad()
    self.padding = 2
    self.anchorFrames = {}
    self.anchorPoints = {}

    local children = {self:GetChildren()}
    local widthUnits = #children

    --[[local widthUnits = 0

    for k, v in ipairs(children) do
        widthUnits = widthUnits + v.widthUnits

    end]]

    if(widthUnits > 0) then
        local divisors = {4, 8, 16, 32, 64, 128}

        if(widthUnits == 2) then
            
        --[[elseif(number == 5) then
            local nearestNumber = findNextNumber(number, divisors)

            if(nearestNumber) then
                local maxDepth = log(nearestNumber) / log(2)

                --self:CreateAnchorFrames(1, maxDepth - 1)

                self:CreateLeftPoint()
                self:CreateAnchorPoints(1, maxDepth - 1)
                self:CreateRightPoint()

                local numAnchorPoints = #self.anchorPoints

                local average = 100 / (numAnchorPoints + 2)
                local childAverage = 100 / number

                local array = {0}

                for i = 1, numAnchorPoints + 1 do
                    tinsert(array, i * average)
                
                end

                tinsert(array, 100)

                print("NUM", numAnchorPoints)

                for i = 1, number do
                    local child = children[i]

                    local num1, index1 = findNextNumber(childAverage * (i - 1), array)
                    local num2, index2 = findNextNumber(childAverage * i , array)

                    local point1, relativeTo1, relativePoint1
                    local point2, relativeTo2, relativePoint2

                    print(i, index1, index2, childAverage * (i - 1), childAverage * (i))

                    if(index1 > 1) then
                        point1, relativeTo1, relativePoint1 = self.anchorPoints[index1].point

                    end

                    if(index2 < numAnchorPoints) then
                        point2, relativeTo2, relativePoint2 = self.anchorPoints[index2].point

                    end

                    child:ClearAllPoints()
                    child:SetPoint("TOPLEFT", relativeTo1 or self, relativePoint1, relativeTo1 and 5 or 0, 0)
                    child:SetPoint("TOPRIGHT", relativeTo2 or self, relativePoint2, relativeTo2 and 5 or 0, 0)
                    
                end
            end]]
        else
            for _, Divisor in ipairs(divisors) do
                if(Divisor>=widthUnits) then
                    local maxDepth = log(Divisor) / log(2)

                    self:CreateAnchorFrames(1, maxDepth - 1)

                    for i = 1, widthUnits do
                        local anchorPointIndex = ceil(i / 2)
                        local even = i % 2 == 0

                        local child = children[i]
                        local anchorFrameData = self.anchorFrames[anchorPointIndex]

                        child:ClearAllPoints()
                        child:SetPoint("TOPLEFT", anchorFrameData.frame, even and "TOP" or "TOPLEFT")
                        child:SetPoint("TOPRIGHT", anchorFrameData.frame, even and "TOPRIGHT" or "TOP")

                    end

                    break
                else

                end
            end
        end
    end
end