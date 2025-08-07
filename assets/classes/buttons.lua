ButtonTextP9UDDT = Core.class(Sprite)

function ButtonTextP9UDDT:init(xparams)
	-- the params table
	self.params = xparams or {}
	-- pixel?
	self.params.pixelcolorup = xparams.pixelcolorup or nil -- color
	self.params.pixelcolordown = xparams.pixelcolordown or self.params.pixelcolorup -- color
	self.params.pixelalpha = xparams.pixelalpha or 1 -- number
	self.params.pixelscalex = xparams.pixelscalex or 1 -- number
	self.params.pixelscaley = xparams.pixelscaley or 1 -- number
	self.params.pixelpaddingx = xparams.pixelpaddingx or 12 -- number
	self.params.pixelpaddingy = xparams.pixelpaddingy or 12 -- number
	-- textures?
	self.params.imgup = xparams.imgup or nil -- img up path
	self.params.imagealpha = xparams.imagealpha or 1 -- number
	self.params.imgscalex = xparams.imgscalex or 1 -- number
	self.params.imgscaley = xparams.imgscaley or self.params.imgscalex -- number
	self.params.imagepaddingx = xparams.imagepaddingx or nil -- number (nil = auto, the image width)
	self.params.imagepaddingy = xparams.imagepaddingy or nil -- number (nil = auto, the image height)
	-- text?
	self.params.text = xparams.text or nil -- string
	self.params.ttf = xparams.ttf or nil -- ttf
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textscalex = xparams.textscalex or 1 -- number
	self.params.textscaley = xparams.textscaley or self.params.textscalex -- number
	-- EXTRAS
	self.params.isautoscale = xparams.isautoscale or nil -- bool
	self.params.width = xparams.width or 0 -- number (default 0)
	self.params.height = xparams.height or 0 -- number (default 0)
	self.params.defaultpadding = xparams.defaultpadding or 16 -- number
	-- draws a pixel around the button to catch the mouse leaving the button
	self.params.catcherx = xparams.catcherx or 32
	self.params.catchery = xparams.catchery or self.params.catcherx
	self.params.catchercolor = xparams.catchercolor or 0x0
	self.params.catcheralpha = xparams.catcheralpha or 0.2
	self.catcher = Pixel.new(self.params.catchercolor, self.params.catcheralpha, 1, 1)
	self:addChild(self.catcher)
	-- button sprite holder
	self.sprite = Sprite.new()
	self:addChild(self.sprite)
	self:setButton()
	-- update visual state
	self.focus = false
	self:updateVisualState()
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

-- FUNCTIONS
function ButtonTextP9UDDT:setButton()
	local textwidth, textheight
	local bmps = {}
	-- text
	if self.params.text then
		self.text = TextField.new(self.params.ttf, self.params.text, self.params.text)
		self.text:setAnchorPoint(0.5, 0.5)
		self.text:setScale(self.params.textscalex, self.params.textscaley)
--		self.text:setTextColor(self.params.textcolorup)
		textwidth, textheight = self.text:getWidth(), self.text:getHeight()
	end
	-- first add pixel
	if self.params.pixelcolorup then
		if self.params.isautoscale and self.params.text then
			self.pixel = Pixel.new(
				self.params.pixelcolor, self.params.pixelalpha,
				textwidth + self.params.pixelpaddingx,
				textheight + self.params.pixelpaddingy)
		else
			self.pixel = Pixel.new(
				self.params.pixelcolor, self.params.pixelalpha,
				self.params.width + self.params.pixelpaddingx,
				self.params.height + self.params.pixelpaddingy)
		end
		self.pixel:setAnchorPoint(0.5, 0.5)
		self.pixel:setScale(self.params.pixelscalex, self.params.pixelscaley)
		self.sprite:addChild(self.pixel)
	end
	-- then images
	if self.params.imgup then
		local texup = Texture.new(self.params.imgup)
		if self.params.isautoscale and self.params.text then
			self.bmpup = Pixel.new(texup,
				textwidth + (self.params.imagepaddingx or self.params.defaultpadding),
				textheight + (self.params.imagepaddingy or self.params.defaultpadding))
		else
			self.bmpup = Pixel.new(texup, self.params.width, self.params.height)
		end
		bmps[self.bmpup] = 1
	end
	-- image batch
	for k, _ in pairs(bmps) do
		k:setAnchorPoint(0.5, 0.5)
		k:setAlpha(self.params.imagealpha)
		local split = 9 -- magik number
		k:setNinePatch(k:getWidth()//split, k:getWidth()//split,
			k:getHeight()//split, k:getHeight()//split)
		self.sprite:addChild(k)
	end
	-- finally add text on top of all
	if self.params.text then self.sprite:addChild(self.text) end
	-- fit the mouse catcher a little bigger than the button
	self.catcher:setDimensions(self.sprite:getWidth() + self.params.catcherx,
		self.sprite:getHeight() + self.params.catchery)
	self.catcher:setAnchorPoint(0.5, 0.5)
end

-- VISUAL STATE
function ButtonTextP9UDDT:updateVisualState()
	if self.toggled then -- button is toggled
		if self.params.imgup ~= nil then self.bmpup:setVisible(false) end
		if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolordown) end
		if self.params.text ~= nil then self.text:setTextColor(0xffffff) end -- magik XXX
	else -- only click events
		if self.focus and self.isclicked then -- button down state
			if self.params.imgup ~= nil and self.params.imgdown ~= nil then self.bmpup:setVisible(false) end
			if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolordown) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolordown) end
		else -- button up state
			if self.params.imgup ~= nil then self.bmpup:setVisible(true) end
			if self.params.pixelcolorup ~= nil then self.pixel:setColor(self.params.pixelcolorup) end
			if self.params.text ~= nil then self.text:setTextColor(self.params.textcolorup) end
		end
	end
end

-- text
function ButtonTextP9UDDT:setText(xtext)
	self.text:setText(xtext)
--	self:updateVisualState()
end
function ButtonTextP9UDDT:getText() return self.text end

-- toggled
function ButtonTextP9UDDT:setToggled(xtoggled)
	self.toggled = xtoggled
	self:updateVisualState()
end
function ButtonTextP9UDDT:isToggled() return self.toggled end

-- MOUSE LISTENERS
function ButtonTextP9UDDT:onMouseDown(e)
	if self:hitTestPoint(e.x, e.y) then
		self.focus = true
		self.isclicked = true
		g_isuibuttondown = true -- perfs
		self:updateVisualState()
		e:stopPropagation()
	end
end
function ButtonTextP9UDDT:onMouseUp(e)
	if self:hitTestPoint(e.x, e.y) then
		if self.focus then
			self.focus = false
			self.isclicked = false
			g_isuibuttondown = false -- for perfs
			self:updateVisualState()
			self:dispatchEvent(Event.new("clicked")) -- button was clicked
			e:stopPropagation()
		end
	else
		if self.focus then
			self.focus = false
			self.isclicked = false
			g_isuibuttondown = false -- for perfs
			self:updateVisualState()
			e:stopPropagation()
		end
	end
end
