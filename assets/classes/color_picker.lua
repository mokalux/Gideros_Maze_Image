ColorPicker = Core.class(Sprite)

function ColorPicker:init(xwidth, xheight)
	-- colors
--	0xFFFFFF, 0x99CCFF, 0xCCFFFF, 0xFFFF99, 0xFFCC99, 0xFF99CC,
--	0xC0C0C0, 0x993366, 0x00CCFF, 0x00FFFF, 0x00FF00, 0xFFFF00,
--	0xFFCC00, 0xFF00FF, 0x999999, 0x800080, 0x3366FF, 0x33CCCC,
--	0x339966, 0x99CC00, 0xFF9900, 0xFF0000, 0x808080, 0x666699,
--	0x0000FF, 0x008080, 0x008000, 0x808000, 0xFF6600, 0x800000,
--	0x333333, 0x333399, 0x000080, 0x333300, 0x993300, 0x000000
	self.colors = {}
	self.colors[#self.colors + 1] = 0xFFFFFF
	self.colors[#self.colors + 1] = 0x99CCFF
	self.colors[#self.colors + 1] = 0xCCFFFF
	self.colors[#self.colors + 1] = 0xFFFF99
	self.colors[#self.colors + 1] = 0xFFCC99
	self.colors[#self.colors + 1] = 0xFF99CC
	-- 2
	self.colors[#self.colors + 1] = 0xC0C0C0
	self.colors[#self.colors + 1] = 0x993366
	self.colors[#self.colors + 1] = 0x00CCFF
	self.colors[#self.colors + 1] = 0x00FFFF
	self.colors[#self.colors + 1] = 0x00FF00
	self.colors[#self.colors + 1] = 0xFFFF00
	-- 3
	self.colors[#self.colors + 1] = 0xFFCC00
	self.colors[#self.colors + 1] = 0xFF00FF
	self.colors[#self.colors + 1] = 0x999999
	self.colors[#self.colors + 1] = 0x800080
	self.colors[#self.colors + 1] = 0x3366FF
	self.colors[#self.colors + 1] = 0x33CCCC
	-- 4
	self.colors[#self.colors + 1] = 0x339966
	self.colors[#self.colors + 1] = 0x99CC00
	self.colors[#self.colors + 1] = 0xFF9900
	self.colors[#self.colors + 1] = 0xFF0000
	self.colors[#self.colors + 1] = 0x808080
	self.colors[#self.colors + 1] = 0x666699
	-- 5
	self.colors[#self.colors + 1] = 0x0000FF
	self.colors[#self.colors + 1] = 0x008080
	self.colors[#self.colors + 1] = 0x008000
	self.colors[#self.colors + 1] = 0x808000
	self.colors[#self.colors + 1] = 0xFF6600
	self.colors[#self.colors + 1] = 0x800000
	-- 6
	self.colors[#self.colors + 1] = 0x333333
	self.colors[#self.colors + 1] = 0x333399
	self.colors[#self.colors + 1] = 0x000080
	self.colors[#self.colors + 1] = 0x333300
	self.colors[#self.colors + 1] = 0x993300
	self.colors[#self.colors + 1] = 0x0
	-- let's go!
	self.currcolor = self.colors[g_bgcolorindex]
	self.colW = xwidth -- cells width
	self.colH = xheight -- cells height
	self.indent = 8 --indent size
	self.numofcols = 6 -- #self.colors
	local ip, fp = math.modf(#self.colors/self.numofcols)
	self.n = ip
	if fp > 0 then self.n = self.n + 1 end
	-- let's go
	self:drawButton(self.currcolor)
	self:drawPalette()
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

function ColorPicker:drawRec(x, y, w, h, borderw, bordercolor, borderalpha, fillcolor, fillalpha)
	local shape = Shape.new()
	shape:setLineStyle(borderw, bordercolor, borderalpha)
	shape:setFillStyle(Shape.SOLID, fillcolor, fillalpha)
	shape:beginPath()
	shape:moveTo(x, y)
	shape:lineTo(x + w, y)
	shape:lineTo(x + w, y + h)
	shape:lineTo(x, y + h)
	shape:closePath()
	shape:endPath()
	return shape
end

function ColorPicker:drawButton(color)
	-- those buttons are only to draw an outline for better visibility
	local btnB = self:drawRec(0, 0, self.colW + 4, self.colH + 4, 1, 0x0, 1, 0x0, 0)
	self:addChild(btnB) -- black outline
	local btnW = self:drawRec(0, 0, self.colW + 2, self.colH + 2, 1, 0xffffff, 1, 0x0, 0)
	self:addChild(btnW) -- white outline
	-- this buttons is only to detect events (mouse, touch, ...)
	-- it's invisible by default but you can change its color and alpha to better suit your needs
	self.btn = self:drawRec(0, 0, self.colW, self.colH, 1, 0x0, 1, 0x0, 0)
	self:addChild(self.btn)
end

function ColorPicker:drawPalette()
	-- draws the colors holder (bg)
	self.palette = self:drawRec(0, self.colH + self.indent,
		self.numofcols * self.colW + self.indent * (self.numofcols + 1), self.n * self.colH + self.indent * (self.n + 1),
		1, 0x0, 1, 0xDDDDDD, 1) -- you can change its color and alpha
	self:addChild(self.palette)
	self.palette:setVisible(false)
	self.palette.colors = {}
	local x, y = 0, self.colH + self.indent
	for i = 1, self.n do
		y = y + self.indent
		for j = 1, self.numofcols do
			if (i - 1) * self.numofcols + j > #self.colors then return end
			x = x + self.indent
			local ci = (i - 1) * self.numofcols + j
			self.palette.colors[ci] = self:drawRec(x, y, self.colW, self.colH, 1, 0x0, 1, self.colors[ci], 1)
			self.palette:addChild(self.palette.colors[ci])
			x = x + self.colW
		end
		x = 0
		y = y + self.colH
	end
end

function ColorPicker:onMouseDown(e)
	if self.btn:hitTestPoint(e.x, e.y) then
		self.palette:setVisible(not self.palette:isVisible())
	end
	if self.palette:isVisible() then
		for i = 1, #self.palette.colors do
			local color = self.palette.colors[i]
			if color:hitTestPoint(e.x, e.y) then
				self.currindex = i
				self.currcolor = self.colors[i]
				self.palette:setVisible(false)
				self.e = Event.new("COLOR_CHANGED")
				self.e.color = self.colors[self.currindex]
				self.e.colorindex = self.currindex
				self:dispatchEvent(self.e)
				e:stopPropagation()
			end
		end
	end
end

function ColorPicker:onMouseUp(e)
	if not self.btn:hitTestPoint(e.x, e.y) then self.palette:setVisible(false) end
end

---- USAGE
--local colorPicker = ColorPicker.new()
--stage:addChild(colorPicker)
--colorPicker:setPosition(10, 10)
--function onColorChanged(e)
--	application:setBackgroundColor(e.color)
--end
--colorPicker:addEventListener("COLOR_CHANGED", onColorChanged)
