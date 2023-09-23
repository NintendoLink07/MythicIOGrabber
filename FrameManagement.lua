local addonName, miog = ...

local function resetPersistentFrames(_, childFrame)
    childFrame:Hide()
	childFrame:ClearAllPoints()
end

local function resetPersistentFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:ClearAllPoints()
end

local function resetPersistentTextures(_, childTexture)
    childTexture:Hide()
	childTexture:ClearAllPoints()
	childTexture:SetTexture(nil)
end

miog.persistentFramePool = CreateFramePoolCollection()
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "DefaultPanelTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "ChatConfigBorderBoxTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelCloseButton", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "BigRedRefreshButtonTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "BackdropTemplate, ScrollFrameTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetPersistentFrames)

miog.persistentFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetPersistentFontStrings)
miog.persistentTexturePool = CreateTexturePool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetPersistentTextures)

local function resetTemporaryFrames(_, childFrame)
    childFrame:Hide()
	childFrame:ClearAllPoints()
	childFrame:SetFrameStrata("LOW")

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:Enable()
		childFrame:SetScript("OnClick", nil)

	elseif(typeOfFrame == "CheckButton") then
		childFrame:SetChecked(false)

	elseif(typeOfFrame == "EditBox") then
		childFrame:ClearFocus()

	elseif(typeOfFrame == "Frame") then
		childFrame:ClearBackdrop()
		childFrame.inviteButton = nil
		childFrame.declineButton = nil
		childFrame.applicantID = nil
		childFrame.entryFrames = {}
		childFrame.statusString = nil
		childFrame.active = false
	end
end

local function resetTemporaryFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:ClearAllPoints()
	childFontString:SetSpacing(2)
	childFontString:SetDrawLayer("BACKGROUND")
	childFontString:SetJustifyH("LEFT")
	childFontString:SetJustifyV("CENTER")
end

local function resetTemporaryTextures(_, childTexture)
    childTexture:Hide()
	childTexture:ClearAllPoints()
	childTexture:SetDrawLayer("BACKGROUND")
	childTexture:SetTexture(nil)
	childTexture:SetTexCoord(0, 1, 0, 1)
end

miog.temporaryFramePool = CreateFramePoolCollection()
miog.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "ThinBorderTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "ScrollFrameTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate, BackdropTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("GameTooltip", nil, "GameTooltipTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("EditBox", nil, "InputBoxTemplate", resetTemporaryFrames)

miog.temporaryFontStringPool = CreateFontStringPool(miog.temporaryFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetTemporaryFontStrings)
miog.temporaryTexturePool = CreateTexturePool(miog.temporaryFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTemporaryTextures)

miog.releaseAllTemporaryPools = function()
	miog.temporaryFramePool:ReleaseAll()
	miog.temporaryFontStringPool:ReleaseAll()
	miog.temporaryTexturePool:ReleaseAll()
end

miog.createFontString = function(text, parent, fontSize, width, height)
	local textLineFontString = miog.temporaryFontStringPool:Acquire()
	textLineFontString:SetFont(miog.fonts["libMono"], fontSize, "OUTLINE")
	textLineFontString:SetJustifyH("LEFT")
	textLineFontString:SetText(text)

	if(width == nil and height == nil) then
		textLineFontString:SetSize(parent:GetWidth(), parent:GetHeight())
	else
		textLineFontString:SetSize(width, height)
	end

	textLineFontString:SetParent(parent)
	textLineFontString:Show()

	return textLineFontString
end

miog.createTextLine = function(anchor, index)
	local textLine = miog.temporaryFramePool:Acquire("BackdropTemplate")
	textLine:SetSize(anchor:GetWidth(), miog.C.ENTRY_FRAME_SIZE, 1, 1)
	textLine:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, (-miog.C.ENTRY_FRAME_SIZE*(index-1)))
	textLine:SetParent(anchor)
	textLine:Show()

	return textLine
end