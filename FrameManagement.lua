local addonName, miog = ...

local function resetPersistentFrames(_, childFrame)
    childFrame:Hide()
	childFrame:ClearAllPoints()
	childFrame:SetFrameStrata("MEDIUM")
	
end

local function resetPersistentFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:ClearAllPoints()
	childFontString:SetDrawLayer("ARTWORK")
end

local function resetPersistentTextures(_, childTexture)
    childTexture:Hide()
	childTexture:ClearAllPoints()
	childTexture:SetTexture(nil)
	childTexture:SetDrawLayer("ARTWORK")
end

miog.persistentFramePool = CreateFramePoolCollection()
miog.persistentFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "BigRedRefreshButtonTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "BackdropTemplate, ScrollFrameTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIPanelButtonTemplate", resetPersistentFrames)
miog.persistentFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate", resetPersistentFrames)

miog.persistentFontStringPool = CreateFontStringPool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetPersistentFontStrings)
miog.persistentTexturePool = CreateTexturePool(miog.persistentFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetPersistentTextures)

local function resetTemporaryFrames(_, childFrame)
    childFrame:Hide()
	childFrame:SetFrameStrata("MEDIUM")

	local typeOfFrame = childFrame:GetObjectType()

	if(typeOfFrame == "Button") then
		childFrame:Enable()
		childFrame:SetScript("OnClick", nil)

	elseif(typeOfFrame == "CheckButton") then
		childFrame:Enable()
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
		childFrame:SetScript("OnEnter", nil)
		childFrame:SetScript("OnLeave", nil)
	end
	
	childFrame:ClearAllPoints()
end

local function resetTemporaryFontStrings(_, childFontString)
    childFontString:Hide()
	childFontString:SetSpacing(2)
	childFontString:SetDrawLayer("BACKGROUND")
	childFontString:SetJustifyV("CENTER")
	childFontString:SetText("")
	childFontString:ClearAllPoints()
end

local function resetTemporaryTextures(_, childTexture)
    childTexture:Hide()
	childTexture:SetDrawLayer("BACKGROUND")
	childTexture:SetTexture(nil)
	childTexture:SetTexCoord(0, 1, 0, 1)
	childTexture:SetDesaturated(false)
	childTexture:ClearAllPoints()
end

miog.temporaryFramePool = CreateFramePoolCollection()
miog.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "BackdropTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("ScrollFrame", nil, "ScrollFrameTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("Button", nil, "UIButtonTemplate, BackdropTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("CheckButton", nil, "UICheckButtonTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("EditBox", nil, "InputBoxTemplate", resetTemporaryFrames)
miog.temporaryFramePool:CreatePoolIfNeeded("Frame", nil, "ResizeLayoutFrame, BackdropTemplate", resetTemporaryFrames)

miog.temporaryFontStringPool = CreateFontStringPool(miog.temporaryFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, "GameTooltipText", resetTemporaryFontStrings)
miog.temporaryTexturePool = CreateTexturePool(miog.temporaryFramePool:Acquire("BackdropTemplate"), "ARTWORK", nil, nil, resetTemporaryTextures)

miog.releaseAllTemporaryPools = function()
	miog.temporaryTexturePool:ReleaseAll()
	miog.temporaryFontStringPool:ReleaseAll()
	miog.temporaryFramePool:ReleaseAll()
end

miog.releaseAllPersistentPools = function()
	miog.persistentTexturePool:ReleaseAll()
	miog.persistentFontStringPool:ReleaseAll()
	miog.persistentFramePool:ReleaseAll()
end

miog.createBaseFrame = function(type, template, parent, width, height)
	local frame

	if(type == "persistent") then
		frame = miog.persistentFramePool:Acquire(template)
	elseif(type == "temporary") then
		frame = miog.temporaryFramePool:Acquire(template)
	end

	frame:SetParent(parent)
	
	if(width and height) then
		frame:SetSize(width, height)

	elseif(width and not height) then
		frame:SetWidth(width)

	elseif(height and not width) then
		frame:SetHeight(height)

	end

	frame:Show()

	return frame
end

miog.createBaseTexture = function(type, texturePath, parent, width, height, layer)
	local texture

	if(type == "persistent") then
		texture = miog.persistentTexturePool:Acquire()
	elseif(type == "temporary") then
		texture = miog.temporaryTexturePool:Acquire()
	end

	texture:SetDrawLayer(layer or "OVERLAY")
	texture:SetParent(parent)
	
	if(width ~= nil) then
		texture:SetWidth(width)
	end
	if(height ~= nil) then
		texture:SetHeight(height)
	end

	if(texture ~= nil) then
		texture:SetTexture(texturePath)
	end

	texture:Show()

	return texture
end

miog.createFrameWithFontStringAttached = function (type, template, parent, width, height)
	local frame, fontString

	if(type == "persistent") then
		frame = miog.persistentFramePool:Acquire(template)
		fontString = miog.persistentFontStringPool:Acquire()
	elseif(type == "temporary") then
		frame = miog.temporaryFramePool:Acquire(template)
		fontString = miog.temporaryFontStringPool:Acquire()
	end

	frame:SetParent(parent)

	if(width and height) then
		frame:SetSize(width, height)

	elseif(width and not height) then
		frame:SetWidth(width)

	elseif(height and not width) then
		frame:SetHeight(height)

	end

	frame:Show()

	fontString:SetFont(miog.fonts["libMono"], miog.C.TEXT_LINE_FONT_SIZE, "OUTLINE")
	fontString:SetPoint("LEFT", frame, "LEFT")
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("CENTER")
	fontString:SetSize(width or 0, height or 0)
	fontString:SetParent(frame)
	fontString:Show()

	frame.fontString = fontString

	return frame
end