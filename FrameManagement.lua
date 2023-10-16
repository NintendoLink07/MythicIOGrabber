local addonName, miog = ...

local function resetFrame(_, childFrame)
    childFrame:Hide()
	childFrame:SetFrameStrata("LOW")

	childFrame.fixedHeight = nil
	childFrame.fixedWidth = nil
	childFrame.minimumHeight = nil
	childFrame.minimumWidth = nil
	childFrame.maximumHeight = nil
	childFrame.maximumWidth = nil
	childFrame.icon = nil
	childFrame.iconSize = nil
	childFrame.iconAtlas = nil

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:Enable()

	elseif(typeOfFrame == "CheckButton") then
		childFrame:Enable()
		childFrame:SetChecked(false)

	elseif(typeOfFrame == "EditBox") then
		childFrame:ClearFocus()
		childFrame:SetScript("OnKeyDown", nil)

	elseif(typeOfFrame == "Frame") then
		childFrame:ClearBackdrop()
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
		childFrame.Texture = nil
		childFrame.FontString = nil

		childFrame.declineButton = nil
		childFrame.inviteButton = nil
		childFrame.linkBox = nil

		childFrame.textRows = nil
		childFrame.mythicPlusTabButton = nil
		childFrame.raidTabButton = nil
		childFrame.rows = nil
		childFrame.memberFrames = nil
		childFrame.textureRows = nil
		childFrame:SetMouseClickEnabled(false)
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
		childFrame:SetScript("OnMouseDown", nil)
	end
	
	childFrame:ClearAllPoints()
end

local function resetFontString(_, childFontString)
    childFontString:Hide()
	childFontString:SetDrawLayer("OVERLAY", -8)
	childFontString:SetText("")
	childFontString:SetJustifyH("LEFT")
	childFontString:SetJustifyV("MIDDLE")
	childFontString:ClearAllPoints()
	childFontString:SetWordWrap(false)
	childFontString:SetSpacing(0)
end

local function resetTexture(_, childTexture)
	childTexture:Hide()
	childTexture:SetDrawLayer("BACKGROUND", -8)
	childTexture:SetTexture(nil)
	childTexture:SetTexCoord(0, 1, 0, 1)
	childTexture:SetDesaturated(false)
	childTexture:ClearAllPoints()
end

miog.persistentFramePool = CreateFramePoolCollection()
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "VerticalLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "HorizontalLayoutFrame, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "ScrollFrameTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "BackdropTemplate, ScrollFrameTemplate", resetFrame)

miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "HeaderSortButtonTemplate", resetFrame)

miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelDynamicResizeButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate, ResizeLayoutFrame", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate, ResizeLayoutFrame", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "IconButtonTemplate, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "RefreshButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate, BackdropTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UICheckButtonTemplate, ResizeLayoutFrame", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetFrame)
miog.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "IconButtonTemplate", resetFrame)

miog.persistentHeaderFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameFontHighlightLarge", resetFontString)
miog.persistentNormalFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)

miog.persistentTexturePool = CreateTexturePool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.fleetingFramePool = CreateFramePoolCollection()
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "TabSystemTemplate, BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "HorizontalLayoutFrame, BackdropTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Frame", nil, "VerticalLayoutFrame, BackdropTemplate", resetFrame)

miog.fleetingFramePool:CreatePoolIfNeeded("EditBox", nil, "InputBoxTemplate", resetFrame)

miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "IconButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate, ResizeLayoutFrame", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("CheckButton", nil, "UIButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetFrame)
miog.fleetingFramePool:CreatePoolIfNeeded("CheckButton", nil, "MaximizeMinimizeButtonFrameTemplate", resetFrame)

miog.fleetingNormalFontStringPool = CreateFontStringPool(miog.fleetingFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)

miog.fleetingTexturePool = CreateTexturePool(miog.fleetingFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.releaseAllFleetingWidgets = function()
	miog.fleetingFramePool:ReleaseAll()
	miog.fleetingNormalFontStringPool:ReleaseAll()
	miog.fleetingTexturePool:ReleaseAll()
end


miog.raidRosterFramePool = CreateFramePool("Frame", nil, "BackdropTemplate", resetFrame)
miog.raidRosterFontStringPool = CreateFontStringPool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "OVERLAY", nil, "GameTooltipText", resetFontString)
miog.raidRosterTexturePool = CreateTexturePool(miog.raidRosterFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTexture)

miog.releaseRaidRosterPool = function()
	miog.raidRosterFramePool:ReleaseAll()
	miog.raidRosterFontStringPool:ReleaseAll()
	miog.raidRosterTexturePool:ReleaseAll()
end

miog.createBasicFrame = function (type, template, parent, width, height, addOn, addOnInfo, addOnInfo2)
	local frame, fontString, texture

	if(type == "persistent") then
		frame = miog.persistentFramePool:Acquire(template)
		fontString = miog.persistentNormalFontStringPool:Acquire()
		texture = miog.persistentTexturePool:Acquire()

	elseif(type == "fleeting") then
		frame = miog.fleetingFramePool:Acquire(template)
		fontString = miog.fleetingNormalFontStringPool:Acquire()
		texture = miog.fleetingTexturePool:Acquire()

	elseif(type == "raidRoster") then
		frame = miog.raidRosterFramePool:Acquire(template)
		fontString = miog.raidRosterFontStringPool:Acquire()
		texture = miog.raidRosterTexturePool:Acquire()
	end

	frame.template = template
	frame:SetParent(parent)
	frame:SetSize(width or 0, height or 0)

	frame:Show()

	if(addOn == "fontstring") then
		fontString:SetFont(miog.FONTS["libMono"], addOnInfo or 16, "OUTLINE")
		fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -1)
		fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
		fontString:SetJustifyH("LEFT")
		fontString:SetText(addOnInfo2 or "")

		fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)

		fontString:SetParent(frame)
		fontString:Show()

		frame.FontString = fontString

	elseif(addOn == "texture") then
		texture:SetTexture(addOnInfo)

		if(width == nil and height == nil) then
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
			texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

		else
			texture:SetPoint("LEFT", frame, "LEFT", 0, 0)
			texture:SetSize(width or 0, height or 0)

		end

		texture:SetParent(frame)
		texture:Show()

		frame.Texture = texture

	elseif(addOn == "texture/fontstring") then
		texture:SetTexture(addOnInfo)

		if(width == nil and height == nil) then
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
			texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)

		else
			texture:SetPoint("LEFT", frame, "LEFT", 0, 0)
			texture:SetSize(width or 0, height or 0)

		end

		texture:SetParent(frame)
		texture:Show()

		frame.Texture = texture

		fontString:SetFont(miog.FONTS["libMono"], addOnInfo2 or 16, "OUTLINE")
		fontString:SetPoint("LEFT", texture, "RIGHT", 0, -1)
		fontString:SetJustifyH("LEFT")
		fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)

		fontString:SetParent(frame)
		fontString:Show()

		frame.FontString = fontString
	end

	return frame
end

miog.createBasicFontString = function(type, fontSize, parent, width, height, text)
	local fontString

	if(type == "persistent") then
		fontString = miog.persistentNormalFontStringPool:Acquire()
	elseif(type == "fleeting") then
		fontString = miog.fleetingNormalFontStringPool:Acquire()
	end

	fontString:SetFont(miog.FONTS["libMono"], fontSize or 16, "OUTLINE")
	fontString:SetJustifyH("LEFT")
	fontString:SetText(text or "")
	fontString:SetSize(width or fontString:GetStringWidth() or 0, height or fontString:GetStringHeight() or 0)

	fontString:SetParent(parent)
	fontString:Show()

	return fontString
end

miog.createBasicTexture = function(type, texturePath, parent, width, height, layer)
	local texture

	if(type == "persistent") then
		texture = miog.persistentTexturePool:Acquire()
	elseif(type == "fleeting") then
		texture = miog.fleetingTexturePool:Acquire()
	end

	texture:SetDrawLayer(layer or "OVERLAY")
	texture:SetParent(parent)
	
	if(width == nil and height == nil) then
		texture:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, -1)
		texture:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)

	else
		texture:SetPoint("LEFT", parent, "LEFT", 0, 0)
		texture:SetSize(width or 0, height or 0)

	end

	texture:SetTexture(texturePath)

	texture:Show()

	return texture
end