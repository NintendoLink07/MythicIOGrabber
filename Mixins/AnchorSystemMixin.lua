AnchorSystemMixin = {}

local framePool = CreateFramePool("Frame")

function AnchorSystemMixin:CreateAnchorFrames(depth, maxDepth, nextParent)
    local frame1 = framePool:Acquire()
    frame1:SetParent(self)
    frame1:SetHeight(1)
    frame1:SetPoint("TOPLEFT", nextParent or self, "TOPLEFT")
    frame1:SetPoint("TOPRIGHT", nextParent or self, "TOP")

    local frame2 = framePool:Acquire()
    frame2:SetParent(self)
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

function AnchorSystemMixin:Reload()
    framePool:ReleaseAll()

    self.anchorFrames = {}
    self.anchorPoints = {}

    local children = {self:GetChildren()}

    local widthUnits = 0

    for k, v in ipairs(children) do
        widthUnits = widthUnits + v.widthUnits

    end

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
                --[[if(Divisor>=widthUnits) then
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
                end]]

                if(Divisor>=widthUnits) then
                    local maxDepth = log(Divisor) / log(2)

                    self:CreateAnchorFrames(1, maxDepth)

                    local index = 0

                    for i = 1, #children do
                        local child = children[i]

                        index = index + 1
                        local anchorFrameDataLeft = self.anchorFrames[index]

                        index = index + child.widthUnits - 1
                        local anchorFrameDataRight = self.anchorFrames[index]

                        child:ClearAllPoints()
                        child:SetPoint("TOPLEFT", anchorFrameDataLeft.frame, "TOPLEFT", self.padding / 2, 0)
                        child:SetPoint("TOPRIGHT", anchorFrameDataRight.frame, "TOPRIGHT", -self.padding / 2, 0)
                        child:Show()

                    end

                    break
                end
            end
        end
    end
end

function AnchorSystemMixin:OnLoad()
    self.padding = 1

    self:Reload()
end