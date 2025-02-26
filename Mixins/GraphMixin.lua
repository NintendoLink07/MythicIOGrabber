GraphMixin = {}

function GraphMixin:OnLoad()
    self.gridPool = EditModeUtil.CreateLinePool(self.Grid, "EditModeGridLineTemplate");
    self.gridSpacing = 20
	hooksecurefunc("UpdateUIParentPosition", function() if self:IsShown() then self:UpdateGrid() end end);

    self.dotPool = CreateTexturePool(self, "ARTWORK", nil, nil, function(pool, frame) frame:SetScript("OnEnter", nil) frame:Hide() frame.line = nil end)
    self.linePool = EditModeUtil.CreateLinePool(self, "EditModeGridLineTemplate");
    self.mod = 1.3
    self.checkboxTable = {}
    self.highestValues = {}

    self:UpdateGrid(true)
end

local editModeGridLinePixelWidth = 1;

local function SetupLineThickness(line, linePixelWidth)
	local lineThickness = PixelUtil.GetNearestPixelSize(linePixelWidth, line:GetEffectiveScale(), linePixelWidth);
	line:SetThickness(lineThickness);
end

function GraphMixin:SetupLine(line, centerLine, verticalLine, xOffset, yOffset)
	local color = centerLine and EDIT_MODE_GRID_CENTER_LINE_COLOR or EDIT_MODE_GRID_LINE_COLOR;
	line:SetColorTexture(color:GetRGBA());

	line:SetStartPoint(verticalLine and "TOP" or "LEFT", self.Grid, xOffset, yOffset);
	line:SetEndPoint(verticalLine and "BOTTOM" or "RIGHT", self.Grid, xOffset, yOffset);

	SetupLineThickness(line, editModeGridLinePixelWidth);
end

function GraphMixin:UpdateGrid(forceUpdate)
	if not self:IsVisible() and not forceUpdate then
		return;
	end

	self.gridPool:ReleaseAll();

	local centerLineNo = false;
	local verticalLine = true;
	local verticalLineNo = false;

	local centerVerticalLine = self.gridPool:Acquire();
	self:SetupLine(centerVerticalLine, centerLineNo, verticalLine, 0, 0);
	centerVerticalLine:Show();

	local centerHorizontalLine = self.gridPool:Acquire();
	self:SetupLine(centerHorizontalLine, centerLineNo, verticalLineNo, 0, 0);
	centerHorizontalLine:Show();

	local halfNumVerticalLines = floor((self.Grid:GetWidth() / self.gridSpacing) / 2);
	local halfNumHorizontalLines = floor((self.Grid:GetHeight() / self.gridSpacing) / 2);

	for i = 1, halfNumVerticalLines do
		local xOffset = i * self.gridSpacing;

		local line = self.gridPool:Acquire();
		self:SetupLine(line, centerLineNo, verticalLine, xOffset, 0);
		line:Show();

		line = self.gridPool:Acquire();
		self:SetupLine(line, centerLineNo, verticalLine, -xOffset, 0);
		line:Show();
	end

	for i = 1, halfNumHorizontalLines do
		local yOffset = i * self.gridSpacing;

		local line = self.gridPool:Acquire();
		self:SetupLine(line, centerLineNo, verticalLineNo, 0, yOffset);
		line:Show();

		line = self.gridPool:Acquire();
		self:SetupLine(line, centerLineNo, verticalLineNo, 0, -yOffset);
		line:Show();
	end
end

function GraphMixin:ResetDatasets()
    self.datasets = {}

    for k, v in ipairs(self.identifiers) do
        self.datasets[v.id] = {}

    end
end

function GraphMixin:SetIdentifiers(tbl, settingsTable, subTable)
    self.identifiers = tbl

    settingsTable[subTable] = settingsTable[subTable] or {}

    self:ResetDatasets()

    local lastCheckbox

    for k, v in ipairs(self.identifiers) do
        local checkbox = CreateFrame("CheckButton", v.name, self.Checkboxes, "MIOG_MinimalCheckButtonWithTextTemplate")
        checkbox:SetSize(60, 22)
        checkbox.id = v.id

        if(lastCheckbox) then
            checkbox:SetPoint("LEFT", lastCheckbox, "RIGHT", 2, 0)

        else
            checkbox:SetPoint("LEFT", 2, 0)

        end

        checkbox.Text:SetText(v.name)
        checkbox.Button:SetScript("OnClick", function(localSelf)
            for _, box in pairs(self.checkboxTable) do
                if(box.Button:GetChecked()) then
                    self:DrawAllDatasets(box.id)
                
                else
                    self:ResetSpecificID(box.id)

                end
            end

            settingsTable[subTable][localSelf:GetParent().id] = localSelf:GetChecked()
        end)
        checkbox.Button:SetChecked(settingsTable[subTable][v.id] or false)
        
        lastCheckbox = checkbox
        self.checkboxTable[v.id] = checkbox
    end
end

function GraphMixin:ResetSpecificID(specificID)
    for line in self.linePool:EnumerateActive() do
        if(line.id == specificID) then
            line.id = nil
            line:SetColorTexture(1, 0, 0, 1);

            self.dotPool:Release(line.dot)
            line.dot = nil

            self.linePool:Release(line)
        end
    end
end

function GraphMixin:ReleaseEverything()
    self:Reset()
    self:ResetDatasets()
end

function GraphMixin:Reset()
    for line in self.linePool:EnumerateActive() do
        line.id = nil
        line.dot = nil
        line:SetColorTexture(1, 0, 0, 1);
    end

    self.dotPool:ReleaseAll()
    self.linePool:ReleaseAll()
end

function GraphMixin:SetModifier(modifier)
    self.mod = modifier

end

function GraphMixin:AddDataset(tbl)
    local highestValue = self.highestValues[tbl.id] or 0

    for k, v in pairs(tbl.values) do
        if(v > highestValue) then
            highestValue = v

        end
    end

    self.highestValues[tbl.id] = highestValue

    tinsert(self.datasets[tbl.id], tbl)
end

function GraphMixin:DrawDataset(tbl, specificID)
    if(specificID and tbl.id == specificID or not specificID) then
        local lastLine

        for k, v in ipairs(tbl.values) do
            local line = self.linePool:Acquire()
            line.id = tbl.id
            
            local color = C_ClassColor.GetClassColor(tbl.class);
            line:SetColorTexture(color:GetRGBA());
        
            line:SetStartPoint(lastLine and "TOPRIGHT" or "BOTTOMLEFT", lastLine or self.Grid, 0, 0);

            line:SetShown(self.checkboxTable[line.id].Button:GetChecked())

            local yOffset = v / (self.highestValues[line.id] * 1.4) * 200

            line:SetEndPoint(lastLine and "TOPRIGHT" or "BOTTOMLEFT", lastLine or self.Grid, 20, yOffset)

            local dot = self.dotPool:Acquire()
            dot.line = line
            dot:SetAtlas("levelup-dot-gold", true)
            dot:SetPoint("CENTER", line, "TOPRIGHT")
            dot:SetSize(14, 14)
            dot:SetScript("OnEnter", function(localSelf)
                GameTooltip:SetOwner(localSelf, "ANCHOR_RIGHT")
                GameTooltip:SetText("Week " .. k)

                table.sort(self.datasets[localSelf.line.id], function(k1, k2)
                    return k1.values[k] > k2.values[k]
                end)
                
                for x, y in ipairs(self.datasets[localSelf.line.id]) do
                    local localColor = C_ClassColor.GetClassColor(y.class)
                    local text = WrapTextInColorCode(y.name, localColor:GenerateHexColor())
                    
                    GameTooltip:AddLine(text .. ": " .. (y.text or y.values[k]))
                end

                GameTooltip:Show()

            end)
            dot:SetScript("OnLeave", GameTooltip_Hide)
            dot:SetShown(line:IsShown())
            line.dot = dot
        
            SetupLineThickness(line, 2)

            lastLine = line
        end
    end
end

function GraphMixin:DrawAllDatasets(specificID)
    for k, v in pairs(self.datasets) do
        for i = 1, #v, 1 do
            self:DrawDataset(v[i], specificID)

        end
    end
end

function GraphMixin:ResetAndDrawAllDatasets(specificID)
    self:Reset()

    for k, v in pairs(self.datasets) do
        for i = 1, #v, 1 do
            self:DrawDataset(v[i], specificID)

        end
    end
end