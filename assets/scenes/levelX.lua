LevelX = Core.class(Sprite)

function LevelX:init()
	-- bg
	application:setBackgroundColor(0x555555)
	-- general prefs init
	g_Xcellcolor = g_Xcellcolor or 0xffffff
	g_Xcellwidth = g_Xcellwidth or 8
	g_Xcellheight = g_Xcellheight or 8
	-- maze size (should be odd)
	g_Xcols = g_Xcols or 17 -- should be odd
	g_Xrows = g_Xrows or 7 -- should be odd
	g_Xseed = g_Xseed or 100
	if g_Xopenend then g_Xopenend = true else g_Xopenend = false end
	-- Tiled UI
	self.layer_ui = Sprite.new()
	self.tiled_ui = LevelX_UI.new("tiled/levelX.lua", self.layer_ui)
	-- a sprite to hold the maze
	self.sprite = Sprite.new()
	-- order
	self:addChild(self.sprite)
	-- let's go!
	self:setCellWidthV()
	self:setCellHeightV()
	self:setMazeColsV()
	self:setMazeRowsV()
	self:setSeedV()
	-- generate and display a random maze
	self.maze = self:createEmptyMazeArray(g_Xcols, g_Xrows)
	self:carveMaze(self.maze, g_Xcols, g_Xrows, g_Xseed, 2, 2) -- starting at x, y (2, 2)
	self:openEndsMaze(self.maze, g_Xcols, g_Xrows)
	self:drawMaze(self.maze, g_Xcols, g_Xrows)
	-- the generated maze on a sprite
	self.sprite:setAnchorPoint(0.5, 0.5)
	self.sprite:setPosition(10*myappwidth/16, 8*myappheight/16)
	-- mouse
	self.currzoom = 1 -- prefs? XXX
	local zoomstart = self.currzoom
	self.sprite:setScale(self.currzoom)
	self.zoomi, self.zoomo = false, false -- shortcut keys for zoom in and zoom out
	-- 1
	local pointerstartx, pointerstarty = 0, 0
	local canvasposx, canvasposy = self.sprite:getPosition()
	local offsetx, offsety = 0, 0
	-- 2
	self.sprite:addEventListener(Event.MOUSE_DOWN, function(e)
		if not g_isuibuttondown then
			pointerstartx, pointerstarty = stage:globalToLocal(e.rx, e.ry)
			e:stopPropagation()
		end
	end)
	self.sprite:addEventListener(Event.MOUSE_MOVE, function(e)
		if not g_isuibuttondown then
			canvasposx, canvasposy = self.sprite:getPosition()
			offsetx = e.rx - pointerstartx
			offsety = e.ry - pointerstarty
			canvasposx += offsetx
			canvasposy += offsety
			self.sprite:setPosition(canvasposx, canvasposy)
			pointerstartx, pointerstarty = stage:globalToLocal(e.rx, e.ry)
			e:stopPropagation()
		end
	end)
	self.sprite:addEventListener(Event.MOUSE_UP, function(e)
		if not g_isuibuttondown then
			e:stopPropagation()
		end
	end)
	-- 3 zoom
	self.sprite:addEventListener(Event.MOUSE_WHEEL, function(e)
		if not g_isuibuttondown then
			zoomstart = self.currzoom
			pointerstartx, pointerstarty = stage:globalToLocal(e.rx, e.ry)
			canvasposx, canvasposy = self.sprite:getPosition()
			-- local viewportZoom=math.clamp(self.zoomStart*2^((self.panStart.ry-newY)/100),_MIN_ZOOM,_MAX_ZOOM)
			self.currzoom = zoomstart + e.wheel/120/8 -- e.wheel/120/4
			if self.currzoom <= 0.1 then self.currzoom = 0.1 end
			if self.currzoom >= 5 then self.currzoom = 5 end
			self.sprite:setScale(self.currzoom)
			local viewportx = canvasposx + (pointerstartx - canvasposx) * (1 - self.currzoom/zoomstart)
			local viewporty = canvasposy + (pointerstarty - canvasposy) * (1 - self.currzoom/zoomstart)
			self.sprite:setPosition(viewportx, viewporty)
			e:stopPropagation()
		end
	end)
	-- btns listeners
	self.tiled_ui.btnrandomseed:addEventListener("clicked", function()
		g_Xseed = math.random(1337)
		mySavePrefs(g_configfilepath)
		self:setSeedV()
	end)
	self.tiled_ui.colorPicker:addEventListener("COLOR_CHANGED", function()
		self:updateMazeColor()
	end)
	self.tiled_ui.btnresetmazepos:addEventListener("clicked", function()
		self.sprite:setAnchorPoint(0.5, 0.5)
		self.sprite:setPosition(10*myappwidth/16, 8*myappheight/16)
	end)
	self.tiled_ui.btnopenend:addEventListener("clicked", function()
		g_Xopenend = not g_Xopenend
		mySavePrefs(g_configfilepath)
		self.tiled_ui.btnopenend:setToggled(g_Xopenend)
		self:openEndsMaze(self.maze, g_Xcols, g_Xrows)
		self:drawMaze(self.maze, g_Xcols, g_Xrows)
	end)
	self.tiled_ui.btnsave:addEventListener("clicked", function()
		mySavePrefs(g_configfilepath)
		if application:getDeviceInfo() ~= "Web" then
			self:exportMaze()
		end
	end)
	self.tiled_ui.btnexit:addEventListener("clicked", function()
		self:gotoScene("menu")
	end)
	-- listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
	-- let's go
	self.tiled_ui.btnopenend:setToggled(g_Xopenend)
end

-- // MAZE GENERATOR IN LUA
-- // Joe Wingbermuehle 2013-10-06
-- // https://raw.githubusercontent.com/joewing/maze/master/maze.lua
function LevelX:createEmptyMazeArray(width, height)
	local result = {}
	for y = 0, height - 1 do
		for x = 0, width - 1 do
			result[y * width + x] = 1
		end
		result[y * width + 0] = 0
		result[y * width + width - 1] = 0
	end
	for x = 0, width - 1 do
		result[0 * width + x] = 0
		result[(height - 1) * width + x] = 0
	end

	return result
end

-- carve the maze starting at x, y
function LevelX:carveMaze(maze, xmazecols, xmazerows, xseed, x, y)
	math.randomseed(xseed)
	local r = math.random(0, 3) -- 0, 3
	maze[y * xmazecols + x] = 0
	for i = 0, 3 do -- 3
		local d = (i + r) % 4
		local dx = 0
		local dy = 0
		if d == 0 then dx = 1
		elseif d == 1 then dx = -1
		elseif d == 2 then dy = 1
		else dy = -1
		end
		local nx = x + dx
		local ny = y + dy
		local nx2 = nx + dx
		local ny2 = ny + dy
		if maze[ny * xmazecols + nx] == 1 then
			if maze[ny2 * xmazecols + nx2] == 1 then
				maze[ny * xmazecols + nx] = 0
				self:carveMaze(maze, xmazecols, xmazerows, math.random(1337), nx2, ny2) -- XXX
			end
		end
	end
end
-- make maze enter and exit
function LevelX:openEndsMaze(maze, xmazecols, xmazerows)
	if g_Xopenend then
		maze[xmazecols + 2] = 0 -- maze initial start XXX
		maze[(xmazerows - 2) * xmazecols + xmazecols - 3] = 0 -- maze initial end XXX
	else
		maze[xmazecols + 2] = 1 -- maze initial start XXX
		maze[(xmazerows - 2) * xmazecols + xmazecols - 3] = 1 -- maze initial end XXX
	end
end
-- draw maze
function LevelX:drawMaze(maze, xmazecols, xmazerows)
	-- the render target
	self.rtfinal = RenderTarget.new(g_Xcellwidth*(xmazecols-2), g_Xcellheight*(xmazerows-2), nil, { pow2=false } )
	-- clear previous maze
	for i = self.sprite:getNumChildren(), 1, -1 do
		self.sprite:removeChildAt(i)
	end
	-- show new maze for the screen
	self.pixies = {}
	for y = 0, xmazerows - 1 do
		for x = 0, xmazecols - 1 do
			if maze[y * xmazecols + x] == 0 then -- nothing here
			else
				local mypix = Pixel.new(g_Xcellcolor, 1, g_Xcellwidth, g_Xcellheight)
				mypix:setPosition(x*mypix:getWidth(), y*mypix:getHeight())
				self.sprite:addChild(mypix)
				self.pixies[#self.pixies+1] = mypix
				-- final maze render target
				self.rtfinal:clear(g_Xcellcolor, 1, (x-1)*g_Xcellwidth, (y-1)*g_Xcellheight, g_Xcellwidth, g_Xcellheight)
			end
		end
	end
end
function LevelX:updateMazeColor()
	self.rtfinal:clear(0x0, 0)
	for i = 1, #self.pixies do
		self.pixies[i]:setColor(g_Xcellcolor)
		-- final maze render target
		self.rtfinal:clear(
			g_Xcellcolor, 1,
			self.pixies[i]:getX()-g_Xcellwidth, self.pixies[i]:getY()-g_Xcellheight,
			g_Xcellwidth, g_Xcellheight
		)
	end
end
function LevelX:makeMaze()
--	mySavePrefs(g_configfilepath)
	self.maze = self:createEmptyMazeArray(g_Xcols, g_Xrows)
	self:carveMaze(self.maze, g_Xcols, g_Xrows, g_Xseed, 2, 2) -- starting at x, y (2, 2)
	self:openEndsMaze(self.maze, g_Xcols, g_Xrows)
	self:drawMaze(self.maze, g_Xcols, g_Xrows)
end
function LevelX:exportMaze()
	mySavePrefs(g_configfilepath)
	local _, destpath = self:checkFolders()
	-- CURRENT DATE AND TIME
	local myyear = os.date("*t").year
	local mymonth = os.date("*t").month; if mymonth < 10 then mymonth = "0"..mymonth end
	local myday = os.date("*t").day; if myday < 10 then myday = "0"..myday end
	local myhour = os.date("*t").hour; if myhour < 10 then myhour = "0"..myhour end
	local mymin = os.date("*t").min; if mymin < 10 then mymin = "0"..mymin end
	local mysec = os.date("*t").sec; if mysec < 10 then mysec = "0"..mysec end
	local mytime = myyear..mymonth..myday.."_"..myhour..mymin..mysec
--	print(mytime) -- 20200309_143048
	-- save maze
	local sep = "/" -- for Qt
	if application:getDeviceInfo() == "Win32" then
		sep = "\\" -- for Win32
	end
	self.rtfinal:save(destpath..sep.."maze_"..(g_Xcols-2).."_"..(g_Xrows-2).."_"..mytime..".png")
	-- play sound
	local snd = Sound.new("audio/glass_05.wav")
	local channel = snd:play()
	channel:setVolume(0.5)
end

-- loop
local modifier = 0
function LevelX:onEnterFrame(e)
	if g_isuibuttondown then -- perfs
		-- special keys modifier
		modifier = 0
		modifier = application:getKeyboardModifiers()
		if modifier & KeyCode.MODIFIER_ALT > 0 then self:modifierAlt()
		elseif modifier & KeyCode.MODIFIER_CTRL > 0 then self:modifierCtrl()
		elseif modifier & KeyCode.MODIFIER_SHIFT > 0 then self:modifierShift()
		else self:modifierNone()
		end
	end
end

-- maze
function LevelX:mazeImageDimInfo()
	self.tiled_ui.tfinfo1:setText(
		"maze image dimensions: ".."\e[color=#0aff]"..g_Xcellwidth*(g_Xcols-2).."\e[color]"..", "..
		"\e[color=#0bff]"..g_Xcellheight*(g_Xrows-2).."\e[color]"
	)
end
function LevelX:setMazeColsV()
	self.tiled_ui.numofcolsv:setText(g_Xcols-2)
	self:mazeImageDimInfo()
	self:makeMaze()
end
function LevelX:setColsM(xstep)
	g_Xcols -= xstep
	if g_Xcols < 5 then g_Xcols = 5 end
	self:setMazeColsV()
end
function LevelX:setColsP(xstep)
	g_Xcols += xstep
	if g_Xcols > 255 then g_Xcols = 255 end
	self:setMazeColsV()
end
--
function LevelX:setMazeRowsV()
	self.tiled_ui.numofrowsv:setText(g_Xrows-2)
	self:mazeImageDimInfo()
	self:makeMaze()
end
function LevelX:setRowsM(xstep)
	g_Xrows -= xstep
	if g_Xrows < 5 then g_Xrows = 5 end
	self:setMazeRowsV()
end
function LevelX:setRowsP(xstep)
	g_Xrows += xstep
	if g_Xrows > 255 then g_Xrows = 255 end
	self:setMazeRowsV()
end
--
function LevelX:setCellWidthV() -- CELL WIDTH
	self.tiled_ui.cellwidthv:setText(g_Xcellwidth)
	self:mazeImageDimInfo()
	self:makeMaze()
end
function LevelX:setCellWidthM(xstep)
	g_Xcellwidth -= xstep
	if g_Xcellwidth < 1 then g_Xcellwidth = 1 end
	self:setCellWidthV()
end
function LevelX:setCellWidthP(xstep)
	g_Xcellwidth += xstep
	if g_Xcellwidth > 128 then g_Xcellwidth = 128 end
	self:setCellWidthV()
end
--
function LevelX:setCellHeightV() -- CELL HEIGHT
	self.tiled_ui.cellheightv:setText(g_Xcellheight)
	self:mazeImageDimInfo()
	self:makeMaze()
end
function LevelX:setCellHeightM(xstep)
	g_Xcellheight -= xstep
	if g_Xcellheight < 1 then g_Xcellheight = 1 end
	self:setCellHeightV()
end
function LevelX:setCellHeightP(xstep)
	g_Xcellheight += xstep
	if g_Xcellheight > 128 then g_Xcellheight = 128 end
	self:setCellHeightV()
end
-- seed
function LevelX:setSeedV()
	self.tiled_ui.seedv:setText(g_Xseed)
	self:makeMaze()
end
function LevelX:setSeedM(xstep)
	g_Xseed -= xstep
	if g_Xseed <= 0 then g_Xseed = 0 end
	self:setSeedV()
end
function LevelX:setSeedP(xstep)
	g_Xseed += xstep
	if g_Xseed >= 1337 then g_Xseed = 1337 end -- XXX
	self:setSeedV()
end

-- continuous
local ctempsteps = 0
local delay = 0
-- __ _  _____
--|_ |_|(_  | 
--|  | |__) | 
function LevelX:modifierAlt()
--	print("xxx")
	if self.tiled_ui.btncellwidthm.isclicked then self:setCellWidthM(2)
	elseif self.tiled_ui.btncellwidthp.isclicked then self:setCellWidthP(2)
	end
	if self.tiled_ui.btncellheightm.isclicked then self:setCellHeightM(2)
	elseif self.tiled_ui.btncellheightp.isclicked then self:setCellHeightP(2)
	end
	if self.tiled_ui.numofcolsm.isclicked then self:setColsM(2)
	elseif self.tiled_ui.numofcolsp.isclicked then self:setColsP(2)
	end
	if self.tiled_ui.numofrowsm.isclicked then self:setRowsM(2)
	elseif self.tiled_ui.numofrowsp.isclicked then self:setRowsP(2)
	end
	if self.tiled_ui.btnseedm.isclicked then self:setSeedM(16)
	elseif self.tiled_ui.btnseedp.isclicked then self:setSeedP(16)
	end
end
--    __ _ ___      
--|V||_ | \ | | ||V|
--| ||__|_/_|_|_|| |
function LevelX:modifierCtrl()
--	print("yyy")
	if self.tiled_ui.btncellwidthm.isclicked then self:setCellWidthM(1)
	elseif self.tiled_ui.btncellwidthp.isclicked then self:setCellWidthP(1)
	end
	if self.tiled_ui.btncellheightm.isclicked then self:setCellHeightM(1)
	elseif self.tiled_ui.btncellheightp.isclicked then self:setCellHeightP(1)
	end
	if self.tiled_ui.numofcolsm.isclicked then self:setColsM(1)
	elseif self.tiled_ui.numofcolsp.isclicked then self:setColsP(1)
	end
	if self.tiled_ui.numofrowsm.isclicked then self:setRowsM(1)
	elseif self.tiled_ui.numofrowsp.isclicked then self:setRowsP(1)
	end
	if self.tiled_ui.btnseedm.isclicked then self:setSeedM(2)
	elseif self.tiled_ui.btnseedp.isclicked then self:setSeedP(2)
	end
end
-- __    _    
--(_ |  / \| |
--__)|__\_/|^|
function LevelX:modifierShift()
--	print("zzz")
	ctempsteps = 16 -- 12
	if self.tiled_ui.btncellwidthm.isclicked then delay+=1 if delay>ctempsteps then self:setCellWidthM(1) delay=0 end
	elseif self.tiled_ui.btncellwidthp.isclicked then delay+=1 if delay>ctempsteps then self:setCellWidthP(1) delay=0 end
	end
	if self.tiled_ui.btncellheightm.isclicked then delay+=1 if delay>ctempsteps then self:setCellHeightM(1) delay=0 end
	elseif self.tiled_ui.btncellheightp.isclicked then delay+=1 if delay>ctempsteps then self:setCellHeightP(1) delay=0 end
	end
	if self.tiled_ui.numofcolsm.isclicked then delay+=1 if delay>ctempsteps then self:setColsM(1) delay=0 end
	elseif self.tiled_ui.numofcolsp.isclicked then delay+=1 if delay>ctempsteps then self:setColsP(1) delay=0 end
	end
	if self.tiled_ui.numofrowsm.isclicked then delay+=1 if delay>ctempsteps then self:setRowsM(1) delay=0 end
	elseif self.tiled_ui.numofrowsp.isclicked then delay+=1 if delay>ctempsteps then self:setRowsP(1) delay=0 end
	end
	if self.tiled_ui.btnseedm.isclicked then delay+=1 if delay>ctempsteps then self:setSeedM(1) delay=0 end
	elseif self.tiled_ui.btnseedp.isclicked then delay+=1 if delay>ctempsteps then self:setSeedP(1) delay=0 end
	end
end
--    _  _     _    
--|\|/ \|_)|V||_||  
--| |\_/| \| || ||__
function LevelX:modifierNone()
--	print("www")
	ctempsteps = 12 -- 8, 10
	if self.zoomi then delay+=1 if delay>ctempsteps then self.currzoom += 0.5
			if self.currzoom >= 10 then self.currzoom = 10 end
			self.sprite:setScale(self.currzoom)
			delay=0
		end
	elseif self.zoomo then delay+=1 if delay>ctempsteps then self.currzoom -= 0.5
			if self.currzoom <= 0.5 then self.currzoom = 0.5 end -- 0.1
			self.sprite:setScale(self.currzoom)
			delay=0
		end
	end
	if self.tiled_ui.btncellwidthm.isclicked then delay+=1 if delay>ctempsteps then self:setCellWidthM(1) delay=0 end
	elseif self.tiled_ui.btncellwidthp.isclicked then delay+=1 if delay>ctempsteps then self:setCellWidthP(1) delay=0 end
	end
	if self.tiled_ui.btncellheightm.isclicked then delay+=1 if delay>ctempsteps then self:setCellHeightM(1) delay=0 end
	elseif self.tiled_ui.btncellheightp.isclicked then delay+=1 if delay>ctempsteps then self:setCellHeightP(1) delay=0 end
	end
	if self.tiled_ui.numofcolsm.isclicked then delay+=1 if delay>ctempsteps then self:setColsM(1) delay=0 end
	elseif self.tiled_ui.numofcolsp.isclicked then delay+=1 if delay>ctempsteps then self:setColsP(1) delay=0 end
	end
	if self.tiled_ui.numofrowsm.isclicked then delay+=1 if delay>ctempsteps then self:setRowsM(1) delay=0 end
	elseif self.tiled_ui.numofrowsp.isclicked then delay+=1 if delay>ctempsteps then self:setRowsP(1) delay=0 end
	end
	if self.tiled_ui.btnseedm.isclicked then delay+=1 if delay>ctempsteps then self:setSeedM(1) delay=0 end
	elseif self.tiled_ui.btnseedp.isclicked then delay+=1 if delay>ctempsteps then self:setSeedP(1) delay=0 end
	end
end

-- EVENT LISTENERS
function LevelX:onTransitionInBegin() end
function LevelX:onTransitionInEnd()
	self:addChild(self.layer_ui) -- fix mouse scenes transition bug
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:myKeysPressed()
end
function LevelX:onTransitionOutBegin()
	self:removeAllListeners()
end
function LevelX:onTransitionOutEnd() end

-- keys handler
function LevelX:myKeysPressed()
	local keymodifier = 0 -- on buttons clicked
	-- shortcuts
	self:addEventListener(Event.KEY_DOWN, function(e) -- KEY_DOWN
		if e.keyCode == KeyCode.NUM_ADD then
			g_isuibuttondown = true
			self.zoomi = true
			self.zoomo = false
		elseif e.keyCode == KeyCode.NUM_SUB then
			g_isuibuttondown = true
			self.zoomi = false
			self.zoomo = true
		elseif e.keyCode == KeyCode.NUM4 then -- SHIFT = arrow left!
			g_isuibuttondown = true
			self.tiled_ui.btnseedm.isclicked = true
			self.tiled_ui.btnseedp.isclicked = false
		elseif e.keyCode == KeyCode.NUM5 then
			g_Xseed = math.random(1337)
			self:setSeedV()
		elseif e.keyCode == KeyCode.NUM6 then -- SHIFT = arrow right!
			g_isuibuttondown = true
			self.tiled_ui.btnseedm.isclicked = false
			self.tiled_ui.btnseedp.isclicked = true
--		elseif e.keyCode == KeyCode.NUM_ENTER then
		elseif e.keyCode == 0 then -- windows, code for KeyCode.NUM_ENTER
			if e.realCode == 553648133 then -- windows, code for KeyCode.NUM_ENTER
				self:exportMaze()
			end
		elseif e.keyCode == 13 then -- win32, code for both KeyCode.ENTER and KeyCode.NUM_ENTER
			if e.realCode == 13 then -- win32, code for both KeyCode.ENTER and KeyCode.NUM_ENTER
				self:exportMaze()
			end
		elseif e.keyCode == KeyCode.ESC then
			self:gotoScene("menu")
		end
--		print("e.keyCode", e.keyCode, "e.realCode", e.realCode, "e.modifiers", e.modifiers) -- debug
	end)
	self:addEventListener(Event.KEY_UP, function(e) -- KEY_UP
		if e.keyCode == KeyCode.NUM_ADD then
			g_isuibuttondown = false
			self.zoomi = false
			self.zoomo = false
			self.currzoom += 0.5
			if self.currzoom >= 10 then self.currzoom = 10 end
			self.sprite:setScale(self.currzoom)
			delay = 0
		elseif e.keyCode == KeyCode.NUM_SUB then
			g_isuibuttondown = false
			self.zoomi = false
			self.zoomo = false
			self.currzoom -= 0.5
			if self.currzoom <= 0.5 then self.currzoom = 0.5 end -- 0.1
			self.sprite:setScale(self.currzoom)
			delay = 0
		elseif e.keyCode == KeyCode.NUM4 then -- SHIFT = arrow left!
			g_isuibuttondown = false
			self.tiled_ui.btnseedm.isclicked = false
			self.tiled_ui.btnseedp.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setSeedM(16)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setSeedM(2)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setSeedM(1)
			else self:setSeedM(1)
			end delay = 0
		elseif e.keyCode == KeyCode.NUM6 then -- SHIFT = arrow right!
			g_isuibuttondown = false
			self.tiled_ui.btnseedm.isclicked = false
			self.tiled_ui.btnseedp.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setSeedP(16)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setSeedP(2)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setSeedP(1)
			else self:setSeedP(1)
			end delay = 0
		end
	end)
	-- buttons
	self.tiled_ui.btncellwidthm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setCellWidthM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setCellWidthM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setCellWidthM(1)
		else self:setCellWidthM(1)
		end delay = 0
	end)
	self.tiled_ui.btncellwidthp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setCellWidthP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setCellWidthP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setCellWidthP(1)
		else self:setCellWidthP(1)
		end delay = 0
	end)
	self.tiled_ui.btncellheightm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setCellHeightM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setCellHeightM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setCellHeightM(1)
		else self:setCellHeightM(1)
		end delay = 0
	end)
	self.tiled_ui.btncellheightp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setCellHeightP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setCellHeightP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setCellHeightP(1)
		else self:setCellHeightP(1)
		end delay = 0
	end)
	self.tiled_ui.numofcolsm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColsM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColsM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColsM(1)
		else self:setColsM(1)
		end delay = 0
	end)
	self.tiled_ui.numofcolsp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColsP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColsP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColsP(1)
		else self:setColsP(1)
		end delay = 0
	end)
	self.tiled_ui.numofrowsm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setRowsM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setRowsM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setRowsM(1)
		else self:setRowsM(1)
		end delay = 0
	end)
	self.tiled_ui.numofrowsp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setRowsP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setRowsP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setRowsP(1)
		else self:setRowsP(1)
		end delay = 0
	end)
	self.tiled_ui.btnseedm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setSeedM(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setSeedM(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setSeedM(1)
		else self:setSeedM(1)
		end delay = 0
	end)
	self.tiled_ui.btnseedp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setSeedP(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setSeedP(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setSeedP(1)
		else self:setSeedP(1)
		end delay = 0
	end)
end

-- check Folders
function LevelX:checkFolders()
	local sep = "/" -- for Qt
	if application:getDeviceInfo() == "Win32" then
		sep = "\\" -- for Win32
	end
	-- check folders: nil=doesn't exist, 1=exists
	if application:get("pathfileexists", application:get("directory", "pictures")..sep.."MazeImage") == nil then
		application:set("mkDir", application:get("directory", "pictures")..sep.."MazeImage")
		application:set("mkDir", application:get("directory", "pictures")..sep.."MazeImage"..sep.."maze")
		application:set("mkDir", application:get("directory", "pictures")..sep.."MazeImage"..sep.."noise")
	end
	-- root
	local root = application:get("directory", "pictures")..sep.."MazeImage"
	-- check folder: nil=doesn't exist, 1=exists
	if application:get("pathfileexists", root) == nil then
		application:set("mkDir", root)
	end
	-- folder
	local folder = application:get("directory", "pictures")..sep.."MazeImage"..sep.."maze"
	-- check folder: nil=doesn't exist, 1=exists
	if application:get("pathfileexists", folder) == nil then
		application:set("mkDir", folder)
	end

	return root, folder
end

-- change scene
function LevelX:gotoScene(xscene)
	mySavePrefs(g_configfilepath)
	scenemanager:changeScene(
		xscene, 1,
		transitions[math.random(1, #transitions)],
		easings[math.random(1, #easings)]
	)
end
