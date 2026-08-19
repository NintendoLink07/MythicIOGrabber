ProgressCheckCellListMixin = {}

function ProgressCheckCellListMixin:Reset()
    self.framePool:ReleaseAll()

end

function ProgressCheckCellListMixin:OnLoad()
    self.framePool = CreateFramePool("Frame", self, self.template or "MIOG_ProgressCheckCharacterColoredCellTemplate", function(pool, frame)
        frame:Hide()
        frame.layoutIndex = nil
        frame.Text:SetText("")

        if(frame.Reset) then
            frame:Reset()

        end
    end)

end

function ProgressCheckCellListMixin:CreateFrame()
    local frame = self.framePool:Acquire()
    frame.layoutIndex = self.framePool:GetNumActive() + 1
    frame:Show()

    return frame

end