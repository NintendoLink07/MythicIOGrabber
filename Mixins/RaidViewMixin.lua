RaidViewMixin = {}

local groupFrames = {
}

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

function RaidViewMixin:FindFrameViaIndex(index) --doesnt really work xd
    local subgroup = ceil(index / 5)
    local spot = index - (5 * (subgroup - 1))

    print("CLEAN", subgroup, spot)

    return groupFrames[subgroup][spot], subgroup, spot
end

function RaidViewMixin:SetMemberValues(subgroup, subgroupFrameIndex, name, fileName)
	--local subgroupSpot = ((memberIndex - 1) % 5) + 1
    --local memberFrame = groupFrames[subgroup][subgroupSpot]
    local memberFrame = groupFrames[subgroup][subgroupFrameIndex]
    print(name, subgroup, subgroupFrameIndex)
    memberFrame:SetID(subgroupFrameIndex)
    memberFrame.subgroup = subgroup

    local classColor  = C_ClassColor.GetClassColor(fileName)

    memberFrame.Text:SetText(name)
    memberFrame.Text:SetTextColor(classColor:GetRGBA())

    memberFrame:Show()
end


function RaidViewMixin:ClearMemberValues(memberIndex)
    local memberFrame = self:FindFrameViaIndex(memberIndex)
    memberFrame:Hide()

    memberFrame.Text:SetText("")

end



RaidViewButtonMixin = {}

function RaidViewButtonMixin:SetCallback(func)
    self.callback = func
end

function RaidViewButtonMixin:ExecuteCallback()
    self.callback(self)
end