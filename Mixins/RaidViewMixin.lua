RaidViewMixin = {}

local groupFrames = {
}

local groupIndexToSubgroupSpot = {}

local function isMouseOverAnyGroupFrame(frame)
    for k, v in ipairs(groupFrames) do
        if(MouseIsOver(v) and v ~= frame) then
            return v
        end
    end
end

local function isMouseOverAnyEmptySpace(frame)
    for k, v in ipairs(spaceFrames) do
        if(MouseIsOver(v)) then
            return v
        end
    end
end

function RaidViewMixin:GetMemberData(memberFrame)
    local data = {}

    data.text = memberFrame.Text:GetText()

    return data
end

function RaidViewMixin:SetMemberData(memberFrame, data)
    memberFrame.Text:SetText(data.text)

end

function RaidViewMixin:SwapMemberData(member1, member2)
    local data1 = self:GetMemberData(member1)
    local data2 = self:GetMemberData(member2)

    self:SetMemberData(member2, data1)
    self:SetMemberData(member1, data2)
end

function RaidViewMixin:SwapMemberPositions(member1, member2)
    if(member1.subgroup ~= member2.subgroup) then
        local index1, index2 = member1:GetID(), member2:GetID()

        print("SWAP", index1, index2)
        SwapRaidSubgroup(index1, index2);
    end
end


function RaidViewMixin:OnLoad()
    for i = 1, 8 do
        local group = self["Group" .. i]
        groupFrames[i] = {}

        for memberIndex = 1, 5 do
            local space = group["Space" .. memberIndex]
            local member = space.MemberFrame
            tinsert(groupFrames[i], member)

            if(member) then
                member:SetCallback(function(selfFrame)
		            if(IsInRaid() and UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
                        local mouseoverFrame = isMouseOverAnyGroupFrame(selfFrame)

                        if(mouseoverFrame) then
                            print(mouseoverFrame.Text:GetText())
                            self:SwapMemberPositions(member, mouseoverFrame)

                        else


                        end
                    end
                end)
            end
        end
    end
end

function RaidViewMixin:FindFrameViaIndex(index)
    local memberFrame = groupIndexToSubgroupSpot[index]

    return memberFrame
end

function RaidViewMixin:SetMemberValues(data)
    local memberFrame = groupFrames[data.subgroup][data.subgroupSpot]
    memberFrame.subgroup = data.subgroup
    memberFrame:SetID(data.index)
    groupIndexToSubgroupSpot[data.index] = {subgroup = data.subgroup, data.subgroupSpot}

    local classColor  = C_ClassColor.GetClassColor(data.fileName)

    memberFrame.Text:SetText(data.name)
    memberFrame.Text:SetTextColor(classColor:GetRGBA())

    memberFrame:Show()
end

function RaidViewMixin:ClearMemberValues(subgroup, index)
    local memberFrame = groupFrames[subgroup][index]
    memberFrame:Hide()

    memberFrame.Text:SetText("")

    local groupIndex = (subgroup - 1) * 5 + index
    groupIndexToSubgroupSpot[groupIndex] = nil
end

function RaidViewMixin:ClearAllMemberValues()
    for subgroup = 1, 8 do
        for index = 1, 5 do
            self:ClearMemberValues(subgroup, index)

        end
    end
end



RaidViewButtonMixin = {}

function RaidViewButtonMixin:SetCallback(func)
    self.callback = func
end

function RaidViewButtonMixin:ExecuteCallback()
    self.callback(self)
end