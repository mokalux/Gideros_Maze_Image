LevelY = Core.class(Sprite)

function LevelY:init()
	g_Ybgcolor = g_Ybgcolor or 0x555555
	application:setBackgroundColor(g_Ybgcolor)
	-- general prefs init
	g_Ynoise = g_Ynoise or 1
	g_Yseed = g_Yseed or 100
	g_Ycolorseed = g_Ycolorseed or 100
	g_Yfrequency = g_Yfrequency or 16
	g_Yoctaves = g_Yoctaves or 3 -- [1...16]
	g_Ylacunarity = g_Ylacunarity or 0 -- [-128...128]
	g_Yinterp = g_Yinterp or 3 -- [1...3], 1=low quality, 3=high quality
	g_Yfractalgain = g_Yfractalgain or 8 -- [-256.0...256.0]
	g_YoffsetX = g_YoffsetX or 0
	g_YoffsetY = g_YoffsetY or 0
	g_Ywidth = g_Ywidth or 128
	g_Yheight = g_Yheight or 128
	g_Ycolorcount = g_Ycolorcount or 1
	g_Yscalex = g_Yscalex or 1
	g_Yscaley = g_Yscaley or 1
	-- UI
	self.layer_ui = Sprite.new()
	self.tiled_ui = LevelY_UI.new("tiled/levelY.lua", self.layer_ui)
	-- a sprite to hold the Noise Maze
	self.sprite = Sprite.new()
	self.tex = Texture.new(nil, g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
--	self.img = Pixel.new(g_Ywidth, g_Yheight, self.tex) -- stretched mode, cannot offset texture :-(
	self.img = Pixel.new(self.tex, g_Ywidth, g_Yheight)
	self.img:setScale(g_Yscalex, g_Yscaley)
	self.sprite:addChild(self.img)
	-- order
	self:addChild(self.sprite) -- then layer_ui is added on top (see onTransitionInEnd)
	-- the noise Maze
	self.n = Noise.new()
	self.n:setNoiseType(noises[g_Ynoise].type) -- Noise.BILLOW
	self.n:setSeed(g_Yseed)
	self.n:setFrequency(g_Yfrequency/1000)
	self.n:setFractalOctaves(g_Yoctaves)
	self.n:setFractalLacunarity(g_Ylacunarity/10)
	self.n:setInterp(interps[g_Yinterp].type) -- Noise.LINEAR, Noise.HERMITE, default = Noise.QUINTIC (lowest to best)
	self.n:setFractalGain(g_Yfractalgain/100) -- 0.6
	self.n:setFractalType(Noise.FBM)
--	local tex = self.n:getTileTexture(g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
--	local tex = self.n:getTexture(g_Ywidth, g_Yheight, false)
	local tex = self.n:getTexture(g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
	self.img:setTexturePosition(g_YoffsetX, g_YoffsetY)
	self.img:setTexture(tex)
	-- let's go!
	self:setNoiseV()
	self:setSeedV()
	self:setColorSeedV()
	self:setFrequencyV()
	self:setOctavesV()
	self:setLacunarityV()
	self:setInterpV()
	self:setFractalGainV()
	self:setOffsetXV()
	self:setOffsetYV()
	self:setWidthV()
	self:setHeightV()
	self:setColorCountV()
	self:setSXV()
	self:setSYV()
	self:generatePalette()
	self:drawMaze()
	-- the generated maze on a sprite
	self.sprite:setAnchorPoint(0.5, 0.5)
	self.sprite:setPosition(10*myappwidth/16, 8*myappheight/16)
	-- mouse
	self.currzoom = 1 -- 1, prefs? XXX
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
			self.currzoom = zoomstart + e.wheel/120/2 -- e.wheel/120/4, e.wheel/120/8
			if self.currzoom <= 0.5 then self.currzoom = 0.5 end -- 0.1
			if self.currzoom >= 10 then self.currzoom = 10 end
			self.sprite:setScale(self.currzoom)
			local viewportx = canvasposx + (pointerstartx - canvasposx) * (1 - self.currzoom/zoomstart)
			local viewporty = canvasposy + (pointerstarty - canvasposy) * (1 - self.currzoom/zoomstart)
			self.sprite:setPosition(viewportx, viewporty)
			e:stopPropagation()
		end
	end)
	-- btns listeners
	self.tiled_ui.colorPicker:addEventListener("COLOR_CHANGED", function()
		application:setBackgroundColor(g_Ybgcolor)
	end)
	self.tiled_ui.btnresetpos:addEventListener("clicked", function()
		self.sprite:setAnchorPoint(0.5, 0.5)
		self.sprite:setPosition(10*myappwidth/16, 8*myappheight/16)
	end)
	self.tiled_ui.btnrandomseed:addEventListener("clicked", function()
		g_Yseed = math.random(1337)
		mySavePrefs(g_configfilepath)
		self:setSeedV()
	end)
	self.tiled_ui.btnrandomcolorseed:addEventListener("clicked", function()
		g_Ycolorseed = math.random(1337)
		mySavePrefs(g_configfilepath)
		self:setColorSeedV()
	end)
	-- reset buttons
	self.tiled_ui.frequencyreset:addEventListener("clicked", function()
		g_Yfrequency = 16
		mySavePrefs(g_configfilepath)
		self:setFrequencyV()
	end)
	self.tiled_ui.octavesreset:addEventListener("clicked", function()
		g_Yoctaves = 3
		mySavePrefs(g_configfilepath)
		self:setOctavesV()
	end)
	self.tiled_ui.lacunarityreset:addEventListener("clicked", function()
		g_Ylacunarity = 0
		mySavePrefs(g_configfilepath)
		self:setLacunarityV()
	end)
	self.tiled_ui.fractalgainreset:addEventListener("clicked", function()
		g_Yfractalgain = 8
		mySavePrefs(g_configfilepath)
		self:setFractalGainV()
	end)
	self.tiled_ui.offsetxreset:addEventListener("clicked", function()
		g_YoffsetX = 0
		mySavePrefs(g_configfilepath)
		self:setOffsetXV()
	end)
	self.tiled_ui.offsetyreset:addEventListener("clicked", function()
		g_YoffsetY = 0
		mySavePrefs(g_configfilepath)
		self:setOffsetYV()
	end)
	self.tiled_ui.widthreset:addEventListener("clicked", function()
		g_Ywidth = 128
		g_Yscalex = 1
		mySavePrefs(g_configfilepath)
		self:setWidthV()
		self:setSXV()
	end)
	self.tiled_ui.heightreset:addEventListener("clicked", function()
		g_Yheight = 128
		g_Yscaley = 1
		mySavePrefs(g_configfilepath)
		self:setHeightV()
		self:setSYV()
	end)
	--
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
end

-- draw maze
function LevelY:generatePalette()
	math.randomseed(g_Ycolorseed)
	local rc0 = math.random(0xffffff)
	local rc1 = math.random(0xffffff)
	local rc2 = math.random(0xffffff)
	local rc3 = math.random(0xffffff)
	local rc4 = math.random(0xffffff)
	local rc5 = math.random(0xffffff)
	local rc6 = math.random(0xffffff)
	local rc7 = math.random(0xffffff)
	local rc8 = math.random(0xffffff)
	local rc9 = math.random(0xffffff)
	if g_Ycolorcount == 1 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.5, rc5, 1},
			}
		)
	elseif g_Ycolorcount == 2 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.5, rc5, 1},
				{0.75, rc6, 1},
			}
		)
	elseif g_Ycolorcount == 3 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.25, rc4, 1},
				{0.5, rc5, 1},
				{0.75, rc6, 1},
			}
		)
	elseif g_Ycolorcount == 4 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.25, rc4, 1},
				{0.5, rc5, 1},
				{0.6666, rc6, 1},
				{0.8333, rc7, 1},
			}
		)
	elseif g_Ycolorcount == 5 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.1666, rc3, 1},
				{0.3333, rc4, 1},
				{0.5, rc5, 1},
				{0.6666, rc6, 1},
				{0.8333, rc7, 1},
			}
		)
	elseif g_Ycolorcount == 6 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.25, rc3, 1},
				{0.375, rc4, 1},
				{0.5, rc5, 1},
				{0.625, rc6, 1},
				{0.75, rc7, 1},
				{0.875, rc8, 1},
			}
		)
	elseif g_Ycolorcount == 7 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.125, rc2, 1},
				{0.25, rc3, 1},
				{0.375, rc4, 1},
				{0.5, rc5, 1},
				{0.625, rc6, 1},
				{0.75, rc7, 1},
				{0.875, rc8, 1},
			}
		)
	elseif g_Ycolorcount == 8 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.2, rc2, 1},
				{0.3, rc3, 1},
				{0.4, rc4, 1},
				{0.5, rc5, 1},
				{0.6, rc6, 1},
				{0.7, rc7, 1},
				{0.8, rc8, 1},
				{0.9, rc9, 1},
			}
		)
	elseif g_Ycolorcount == 9 then
		self.n:setColorLookup(
			{
				{0.0, rc0, 1},
				{0.1, rc1, 1},
				{0.2, rc2, 1},
				{0.3, rc3, 1},
				{0.4, rc4, 1},
				{0.5, rc5, 1},
				{0.6, rc6, 1},
				{0.7, rc7, 1},
				{0.8, rc8, 1},
				{0.9, rc9, 1},
			}
		)
	elseif g_Ycolorcount == 10 then
		self.n:setColorLookup(
			{
				{0.0, math.random(0xffffff), 1},
				{0.05, math.random(0xffffff), 1},
				{0.1, math.random(0xffffff), 1},
				{0.15, math.random(0xffffff), 1},
				{0.2, math.random(0xffffff), 1},
				{0.25, math.random(0xffffff), 1},
				{0.3, math.random(0xffffff), 1},
				{0.35, math.random(0xffffff), 1},
				{0.4, math.random(0xffffff), 1},
				{0.45, math.random(0xffffff), 1},
				{0.5, math.random(0xffffff), 1},
				{0.55, math.random(0xffffff), 1},
				{0.6, math.random(0xffffff), 1},
				{0.65, math.random(0xffffff), 1},
				{0.7, math.random(0xffffff), 1},
				{0.75, math.random(0xffffff), 1},
				{0.8, math.random(0xffffff), 1},
				{0.85, math.random(0xffffff), 1},
				{0.9, math.random(0xffffff), 1},
				{0.95, math.random(0xffffff), 1},
			}
		)
	end
	self:drawMaze()
end
-- draw maze
function LevelY:drawMaze()
	-- the Noise image
--	local tex = self.n:getTileTexture(g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
--	local tex = self.n:getTexture(g_Ywidth, g_Yheight, false)
	local tex = self.n:getTexture(g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
	self.img:setTexture(tex)
	-- the render target
--	self.rtfinal = RenderTarget.new(g_Ywidth, g_Yheight, false, { wrap=TextureBase.REPEAT, extend=true, } )
	self.rtfinal = RenderTarget.new(g_Ywidth*g_Yscalex, g_Yheight*g_Yscaley, false, { wrap=TextureBase.REPEAT, extend=true, } )
	self.rtfinal:draw(self.img)
end
-- export maze
function LevelY:exportMaze()
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
	self.rtfinal:save(destpath..sep.."noise_"..g_Ywidth*g_Yscalex.."_"..g_Yheight*g_Yscaley.."_"..mytime..".png")
	-- play sound
	local snd = Sound.new("audio/glass_05.wav")
	local channel = snd:play()
	channel:setVolume(0.5)
end

-- loop
local modifier = 0
function LevelY:onEnterFrame(e)
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

function LevelY:mazeImageDimInfo()
	self.tiled_ui.tfinfo1:setText(
		"image dimensions: ".."\e[color=#0aff]"..g_Ywidth*g_Yscalex.."\e[color]"..", "..
		"\e[color=#0bff]"..g_Yheight*g_Yscaley.."\e[color]"
	)
end
function LevelY:setNoiseV()
	self.tiled_ui.noisev:setText(tostring(g_Ynoise).." "..noises[g_Ynoise].name)
	self.n:setNoiseType(noises[g_Ynoise].type) -- Noise.BILLOW
	self:drawMaze()
end
function LevelY:setNoiseM(xstep)
	g_Ynoise -= xstep
	if g_Ynoise < 1 then g_Ynoise = #noises end
	self:setNoiseV()
end
function LevelY:setNoiseP(xstep)
	g_Ynoise += xstep
	if g_Ynoise > #noises then g_Ynoise = 1 end
	self:setNoiseV()
end
function LevelY:setSeedV()
	self.tiled_ui.seedv:setText(g_Yseed)
	self.n:setSeed(g_Yseed)
	self:drawMaze()
end
function LevelY:setSeedM(xstep)
	g_Yseed -= xstep
	if g_Yseed <= 0 then g_Yseed = 0 end
	self:setSeedV()
end
function LevelY:setSeedP(xstep)
	g_Yseed += xstep
	if g_Yseed >= 1337 then g_Yseed = 1337 end
	self:setSeedV()
end
--
function LevelY:setColorSeedV()
	self.tiled_ui.colorseedv:setText(g_Ycolorseed)
	self:generatePalette()
end
function LevelY:setColorSeedM(xstep)
	g_Ycolorseed -= xstep
	if g_Ycolorseed <= 0 then g_Ycolorseed = 0 end
	self:setColorSeedV()
end
function LevelY:setColorSeedP(xstep)
	g_Ycolorseed += xstep
	if g_Ycolorseed >= 1337 then g_Ycolorseed = 1337 end
	self:setColorSeedV()
end
--
function LevelY:setFrequencyV()
	self.tiled_ui.frequencyv:setText(g_Yfrequency)
	self.n:setFrequency(g_Yfrequency/1000)
	self:drawMaze()
end
function LevelY:setFrequencyM(xstep)
	g_Yfrequency -= xstep
	if g_Yfrequency <= -128 then g_Yfrequency = -128 end
	self:setFrequencyV()
end
function LevelY:setFrequencyP(xstep)
	g_Yfrequency += xstep
	if g_Yfrequency >= 128 then g_Yfrequency = 128 end
	self:setFrequencyV()
end
function LevelY:setOctavesV()
	self.tiled_ui.octavesv:setText(g_Yoctaves)
	self.n:setFractalOctaves(g_Yoctaves)
	self:drawMaze()
end
function LevelY:setOctavesM(xstep)
	g_Yoctaves -= xstep
	if g_Yoctaves <= 1 then g_Yoctaves = 1 end
	self:setOctavesV()
end
function LevelY:setOctavesP(xstep)
	g_Yoctaves += xstep
	if g_Yoctaves >= 16 then g_Yoctaves = 16 end
	self:setOctavesV()
end
function LevelY:setLacunarityV()
	self.tiled_ui.lacunarityv:setText(g_Ylacunarity)
	self.n:setFractalLacunarity(g_Ylacunarity/10)
	self:drawMaze()
end
function LevelY:setLacunarityM(xstep)
	g_Ylacunarity -= xstep
	if g_Ylacunarity <= -128 then g_Ylacunarity = -128 end
	self:setLacunarityV()
end
function LevelY:setLacunarityP(xstep)
	g_Ylacunarity += xstep
	if g_Ylacunarity >= 128 then g_Ylacunarity = 128 end
	self:setLacunarityV()
end
function LevelY:setInterpV()
	self.tiled_ui.interpv:setText(tostring(g_Yinterp).." "..interps[g_Yinterp].name)
	self.n:setInterp(interps[g_Yinterp].type) -- Noise.LINEAR, Noise.HERMITE, default = Noise.QUINTIC (lowest to best)
	self:drawMaze()
end
function LevelY:setInterpM(xstep)
	g_Yinterp -= xstep
	if g_Yinterp < 1 then g_Yinterp = #interps end
	self:setInterpV()
end
function LevelY:setInterpP(xstep)
	g_Yinterp += xstep
	if g_Yinterp > #interps then g_Yinterp = 1 end
	self:setInterpV()
end
function LevelY:setFractalGainV()
	self.tiled_ui.fractalgainv:setText(g_Yfractalgain)
	self.n:setFractalGain(g_Yfractalgain/100) -- 0.6
	self:drawMaze()
end
function LevelY:setFractalGainM(xstep)
	g_Yfractalgain -= xstep
	if g_Yfractalgain <= -256 then g_Yfractalgain = -256 end
	self:setFractalGainV()
end
function LevelY:setFractalGainP(xstep)
	g_Yfractalgain += xstep
	if g_Yfractalgain >= 256 then g_Yfractalgain = 256 end
	self:setFractalGainV()
end
-- img (Pixel)
function LevelY:setOffsetXV()
	self.tiled_ui.offsetxv:setText(g_YoffsetX)
	self.img:setTexturePosition(g_YoffsetX, g_YoffsetY)
	self:drawMaze()
end
function LevelY:setOffsetXM(xstep)
	g_YoffsetX -= xstep
	if g_YoffsetX < -g_Ywidth then g_YoffsetX = g_Ywidth end
	self:setOffsetXV()
end
function LevelY:setOffsetXP(xstep)
	g_YoffsetX += xstep
	if g_YoffsetX > g_Ywidth then g_YoffsetX = -g_Ywidth end
	self:setOffsetXV()
end
function LevelY:setOffsetYV()
	self.tiled_ui.offsetyv:setText(g_YoffsetY)
	self.img:setTexturePosition(g_YoffsetX, g_YoffsetY)
	self:drawMaze()
end
function LevelY:setOffsetYM(xstep)
	g_YoffsetY -= xstep
	if g_YoffsetY < -g_Yheight then g_YoffsetY = g_Yheight end
	self:setOffsetYV()
end
function LevelY:setOffsetYP(xstep)
	g_YoffsetY += xstep
	if g_YoffsetY > g_Yheight then g_YoffsetY = -g_Yheight end
	self:setOffsetYV()
end
--
function LevelY:setWidthV()
	self.tiled_ui.widthv:setText(g_Ywidth)
	self:mazeImageDimInfo()
	self.img:setDimensions(g_Ywidth, g_Yheight)
	self:drawMaze()
end
function LevelY:setWidthM(xstep)
	g_Ywidth -= xstep
	if g_Ywidth <= 8 then g_Ywidth = 8 end
	self:setWidthV()
end
function LevelY:setWidthP(xstep)
	g_Ywidth += xstep
	if g_Ywidth >= 1024 then g_Ywidth = 1024 end -- 2048
	self:setWidthV()
end
function LevelY:setHeightV()
	self.tiled_ui.heightv:setText(g_Yheight)
	self:mazeImageDimInfo()
	self.img:setDimensions(g_Ywidth, g_Yheight)
	self:drawMaze()
end
function LevelY:setHeightM(xstep)
	g_Yheight -= xstep
	if g_Yheight <= 8 then g_Yheight = 8 end
	self:setHeightV()
end
function LevelY:setHeightP(xstep)
	g_Yheight += xstep
	if g_Yheight >= 1024 then g_Yheight = 1024 end -- 2048
	self:setHeightV()
end
function LevelY:setColorCountV()
	self.tiled_ui.btncolorcount:setText(g_Ycolorcount)
	self:generatePalette()
end
function LevelY:setColorCount()
	g_Ycolorcount += 1
	if g_Ycolorcount > 10 then g_Ycolorcount = 1 end -- magik XXX
	self:setColorCountV()
end
function LevelY:setSXV()
	self.tiled_ui.btnscalex:setText(g_Yscalex)
	self:mazeImageDimInfo()
	self.img:setScaleX(g_Yscalex)
	self:drawMaze()
end
function LevelY:setSX()
	g_Yscalex += 1
	if g_Yscalex > 4 then g_Yscalex = 1 end
	self:setSXV()
end
function LevelY:setSYV()
	self.tiled_ui.btnscaley:setText(g_Yscaley)
	self:mazeImageDimInfo()
	self.img:setScaleY(g_Yscaley)
	self:drawMaze()
end
function LevelY:setSY()
	g_Yscaley += 1
	if g_Yscaley > 4 then g_Yscaley = 1 end
	self:setSYV()
end

-- continuous
local ctempsteps = 0
local delay = 0
-- __ _  _____
--|_ |_|(_  | 
--|  | |__) | 
function LevelY:modifierAlt()
--	print("xxx")
	if self.tiled_ui.btnnoisem.isclicked then self:setNoiseM(2)
	elseif self.tiled_ui.btnnoisep.isclicked then self:setNoiseP(2)
	end
	if self.tiled_ui.btnseedm.isclicked then self:setSeedM(16)
	elseif self.tiled_ui.btnseedp.isclicked then self:setSeedP(16)
	end
	if self.tiled_ui.btncolorseedm.isclicked then self:setColorSeedM(16)
	elseif self.tiled_ui.btncolorseedp.isclicked then self:setColorSeedP(16)
	end
	if self.tiled_ui.btnfrequencym.isclicked then self:setFrequencyM(2)
	elseif self.tiled_ui.btnfrequencyp.isclicked then self:setFrequencyP(2)
	end
	if self.tiled_ui.btnoctavesm.isclicked then self:setOctavesM(2)
	elseif self.tiled_ui.btnoctavesp.isclicked then self:setOctavesP(2)
	end
	if self.tiled_ui.btnlacunaritym.isclicked then self:setLacunarityM(2)
	elseif self.tiled_ui.btnlacunarityp.isclicked then self:setLacunarityP(2)
	end
	if self.tiled_ui.btninterpm.isclicked then self:setInterpM(1)
	elseif self.tiled_ui.btninterpp.isclicked then self:setInterpP(1)
	end
	if self.tiled_ui.btnfractalgainm.isclicked then self:setFractalGainM(8)
	elseif self.tiled_ui.btnfractalgainp.isclicked then self:setFractalGainP(8)
	end
	--
	if self.tiled_ui.widthm.isclicked then self:setWidthM(128)
	elseif self.tiled_ui.widthp.isclicked then self:setWidthP(128)
	end
	if self.tiled_ui.heightm.isclicked then self:setHeightM(128)
	elseif self.tiled_ui.heightp.isclicked then self:setHeightP(128)
	end
	if self.tiled_ui.btnoffsetxm.isclicked then self:setOffsetXM(16)
	elseif self.tiled_ui.btnoffsetxp.isclicked then self:setOffsetXP(16)
	end
	if self.tiled_ui.btnoffsetym.isclicked then self:setOffsetYM(16)
	elseif self.tiled_ui.btnoffsetyp.isclicked then self:setOffsetYP(16)
	end
end
--    __ _ ___      
--|V||_ | \ | | ||V|
--| ||__|_/_|_|_|| |
function LevelY:modifierCtrl()
--	print("yyy")
	if self.tiled_ui.btnnoisem.isclicked then self:setNoiseM(1)
	elseif self.tiled_ui.btnnoisep.isclicked then self:setNoiseP(1)
	end
	if self.tiled_ui.btnseedm.isclicked then self:setSeedM(1)
	elseif self.tiled_ui.btnseedp.isclicked then self:setSeedP(1)
	end
	if self.tiled_ui.btncolorseedm.isclicked then self:setColorSeedM(1)
	elseif self.tiled_ui.btncolorseedp.isclicked then self:setColorSeedP(1)
	end
	if self.tiled_ui.btnfrequencym.isclicked then self:setFrequencyM(1)
	elseif self.tiled_ui.btnfrequencyp.isclicked then self:setFrequencyP(1)
	end
	if self.tiled_ui.btnoctavesm.isclicked then self:setOctavesM(1)
	elseif self.tiled_ui.btnoctavesp.isclicked then self:setOctavesP(1)
	end
	if self.tiled_ui.btnlacunaritym.isclicked then self:setLacunarityM(1)
	elseif self.tiled_ui.btnlacunarityp.isclicked then self:setLacunarityP(1)
	end
	if self.tiled_ui.btninterpm.isclicked then self:setInterpM(1)
	elseif self.tiled_ui.btninterpp.isclicked then self:setInterpP(1)
	end
	if self.tiled_ui.btnfractalgainm.isclicked then self:setFractalGainM(1)
	elseif self.tiled_ui.btnfractalgainp.isclicked then self:setFractalGainP(1)
	end
	--
	if self.tiled_ui.widthm.isclicked then self:setWidthM(32)
	elseif self.tiled_ui.widthp.isclicked then self:setWidthP(32)
	end
	if self.tiled_ui.heightm.isclicked then self:setHeightM(32)
	elseif self.tiled_ui.heightp.isclicked then self:setHeightP(32)
	end
	if self.tiled_ui.btnoffsetxm.isclicked then self:setOffsetXM(1)
	elseif self.tiled_ui.btnoffsetxp.isclicked then self:setOffsetXP(1)
	end
	if self.tiled_ui.btnoffsetym.isclicked then self:setOffsetYM(1)
	elseif self.tiled_ui.btnoffsetyp.isclicked then self:setOffsetYP(1)
	end
end
-- __    _    
--(_ |  / \| |
--__)|__\_/|^|
function LevelY:modifierShift()
--	print("zzz")
	ctempsteps = 16 -- 12
	if self.tiled_ui.btnnoisem.isclicked then delay+=1 if delay>ctempsteps then self:setNoiseM(1) delay=0 end
	elseif self.tiled_ui.btnnoisep.isclicked then delay+=1 if delay>ctempsteps then self:setNoiseP(1) delay=0 end
	end
	if self.tiled_ui.btnseedm.isclicked then delay+=1 if delay>ctempsteps then self:setSeedM(1) delay=0 end
	elseif self.tiled_ui.btnseedp.isclicked then delay+=1 if delay>ctempsteps then self:setSeedP(1) delay=0 end
	end
	if self.tiled_ui.btncolorseedm.isclicked then delay+=1 if delay>ctempsteps then self:setColorSeedM(1) delay=0 end
	elseif self.tiled_ui.btncolorseedp.isclicked then delay+=1 if delay>ctempsteps then self:setColorSeedP(1) delay=0 end
	end
	if self.tiled_ui.btnfrequencym.isclicked then delay+=1 if delay>ctempsteps then self:setFrequencyM(1) delay=0 end
	elseif self.tiled_ui.btnfrequencyp.isclicked then delay+=1 if delay>ctempsteps then self:setFrequencyP(1) delay=0 end
	end
	if self.tiled_ui.btnoctavesm.isclicked then delay+=1 if delay>ctempsteps then self:setOctavesM(1) delay=0 end
	elseif self.tiled_ui.btnoctavesp.isclicked then delay+=1 if delay>ctempsteps then self:setOctavesP(1) delay=0 end
	end
	if self.tiled_ui.btnlacunaritym.isclicked then delay+=1 if delay>ctempsteps then self:setLacunarityM(1) delay=0 end
	elseif self.tiled_ui.btnlacunarityp.isclicked then delay+=1 if delay>ctempsteps then self:setLacunarityP(1) delay=0 end
	end
	if self.tiled_ui.btninterpm.isclicked then delay+=1 if delay>ctempsteps then self:setInterpM(1) delay=0 end
	elseif self.tiled_ui.btninterpp.isclicked then delay+=1 if delay>ctempsteps then self:setInterpP(1) delay=0 end
	end
	if self.tiled_ui.btnfractalgainm.isclicked then delay+=1 if delay>ctempsteps then self:setFractalGainM(1) delay=0 end
	elseif self.tiled_ui.btnfractalgainp.isclicked then delay+=1 if delay>ctempsteps then self:setFractalGainP(1) delay=0 end
	end
	--
	if self.tiled_ui.widthm.isclicked then delay+=1 if delay>ctempsteps then self:setWidthM(1) delay=0 end
	elseif self.tiled_ui.widthp.isclicked then delay+=1 if delay>ctempsteps then self:setWidthP(1) delay=0 end
	end
	if self.tiled_ui.heightm.isclicked then delay+=1 if delay>ctempsteps then self:setHeightM(1) delay=0 end
	elseif self.tiled_ui.heightp.isclicked then delay+=1 if delay>ctempsteps then self:setHeightP(1) delay=0 end
	end
	if self.tiled_ui.btnoffsetxm.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetXM(1) delay=0 end
	elseif self.tiled_ui.btnoffsetxp.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetXP(1) delay=0 end
	end
	if self.tiled_ui.btnoffsetym.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetYM(1) delay=0 end
	elseif self.tiled_ui.btnoffsetyp.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetYP(1) delay=0 end
	end
end
--    _  _     _    
--|\|/ \|_)|V||_||  
--| |\_/| \| || ||__
function LevelY:modifierNone()
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
	if self.tiled_ui.btnnoisem.isclicked then delay+=1 if delay>ctempsteps then self:setNoiseM(1) delay=0 end
	elseif self.tiled_ui.btnnoisep.isclicked then delay+=1 if delay>ctempsteps then self:setNoiseP(1) delay=0 end
	end
	if self.tiled_ui.btnseedm.isclicked then delay+=1 if delay>ctempsteps then self:setSeedM(1) delay=0 end
	elseif self.tiled_ui.btnseedp.isclicked then delay+=1 if delay>ctempsteps then self:setSeedP(1) delay=0 end
	end
	if self.tiled_ui.btncolorseedm.isclicked then delay+=1 if delay>ctempsteps then self:setColorSeedM(1) delay=0 end
	elseif self.tiled_ui.btncolorseedp.isclicked then delay+=1 if delay>ctempsteps then self:setColorSeedP(1) delay=0 end
	end
	if self.tiled_ui.btnfrequencym.isclicked then delay+=1 if delay>ctempsteps then self:setFrequencyM(1) delay=0 end
	elseif self.tiled_ui.btnfrequencyp.isclicked then delay+=1 if delay>ctempsteps then self:setFrequencyP(1) delay=0 end
	end
	if self.tiled_ui.btnoctavesm.isclicked then delay+=1 if delay>ctempsteps then self:setOctavesM(1) delay=0 end
	elseif self.tiled_ui.btnoctavesp.isclicked then delay+=1 if delay>ctempsteps then self:setOctavesP(1) delay=0 end
	end
	if self.tiled_ui.btnlacunaritym.isclicked then delay+=1 if delay>ctempsteps then self:setLacunarityM(1) delay=0 end
	elseif self.tiled_ui.btnlacunarityp.isclicked then delay+=1 if delay>ctempsteps then self:setLacunarityP(1) delay=0 end
	end
	if self.tiled_ui.btninterpm.isclicked then delay+=1 if delay>ctempsteps then self:setInterpM(1) delay=0 end
	elseif self.tiled_ui.btninterpp.isclicked then delay+=1 if delay>ctempsteps then self:setInterpP(1) delay=0 end
	end
	if self.tiled_ui.btnfractalgainm.isclicked then delay+=1 if delay>ctempsteps then self:setFractalGainM(1) delay=0 end
	elseif self.tiled_ui.btnfractalgainp.isclicked then delay+=1 if delay>ctempsteps then self:setFractalGainP(1) delay=0 end
	end
	--
	if self.tiled_ui.widthm.isclicked then delay+=1 if delay>ctempsteps then self:setWidthM(8) delay=0 end
	elseif self.tiled_ui.widthp.isclicked then delay+=1 if delay>ctempsteps then self:setWidthP(8) delay=0 end
	end
	if self.tiled_ui.heightm.isclicked then delay+=1 if delay>ctempsteps then self:setHeightM(8) delay=0 end
	elseif self.tiled_ui.heightp.isclicked then delay+=1 if delay>ctempsteps then self:setHeightP(8) delay=0 end
	end
	if self.tiled_ui.btnoffsetxm.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetXM(1) delay=0 end
	elseif self.tiled_ui.btnoffsetxp.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetXP(1) delay=0 end
	end
	if self.tiled_ui.btnoffsetym.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetYM(1) delay=0 end
	elseif self.tiled_ui.btnoffsetyp.isclicked then delay+=1 if delay>ctempsteps then self:setOffsetYP(1) delay=0 end
	end
end

-- EVENT LISTENERS
function LevelY:onTransitionInBegin() end
function LevelY:onTransitionInEnd()
	self:addChild(self.layer_ui) -- fix mouse scenes transition bug
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
--	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
--	self:addEventListener(Event.KEY_UP, self.onKeyUp, self)
	self:myKeysPressed()
end
function LevelY:onTransitionOutBegin()
	self:removeAllListeners()
end
function LevelY:onTransitionOutEnd() end

-- keys handler
function LevelY:myKeysPressed()
	local keymodifier = 0
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
		--
		elseif e.keyCode == KeyCode.NUM7 then
			g_isuibuttondown = true
			self.tiled_ui.btnnoisem.isclicked = true
			self.tiled_ui.btnnoisep.isclicked = false
		elseif e.keyCode == KeyCode.NUM9 then
			g_isuibuttondown = true
			self.tiled_ui.btnnoisem.isclicked = false
			self.tiled_ui.btnnoisep.isclicked = true
		elseif e.keyCode == KeyCode.NUM8 then
			g_Ynoise = math.random(#noises)
			mySavePrefs(g_configfilepath)
			self:setNoiseV()
		elseif e.keyCode == KeyCode.NUM4 then
			g_isuibuttondown = true
			self.tiled_ui.btnseedm.isclicked = true
			self.tiled_ui.btnseedp.isclicked = false
		elseif e.keyCode == KeyCode.NUM6 then
			g_isuibuttondown = true
			self.tiled_ui.btnseedm.isclicked = false
			self.tiled_ui.btnseedp.isclicked = true
		elseif e.keyCode == KeyCode.NUM5 then -- randomize seed
			g_Yseed = math.random(1337)
			mySavePrefs(g_configfilepath)
			self:setSeedV()
		elseif e.keyCode == KeyCode.NUM0 then
			self.n:setColorLookup(nil)
			self:drawMaze()
		elseif e.keyCode == KeyCode.NUM_DOT then
			mySavePrefs(g_configfilepath)
			self:setColorCount()
		elseif e.keyCode == KeyCode.NUM1 then
			g_isuibuttondown = true
			self.tiled_ui.btncolorseedm.isclicked = true
			self.tiled_ui.btncolorseedp.isclicked = false
		elseif e.keyCode == KeyCode.NUM2 then
			g_Ycolorseed = math.random(1337)
			mySavePrefs(g_configfilepath)
			self:setColorSeedV()
		elseif e.keyCode == KeyCode.NUM3 then
			g_isuibuttondown = true
			self.tiled_ui.btncolorseedm.isclicked = false
			self.tiled_ui.btncolorseedp.isclicked = true
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
		elseif e.keyCode == KeyCode.NUM7 then -- SHIFT = home!
			g_isuibuttondown = false
			self.tiled_ui.btnnoisem.isclicked = false
			self.tiled_ui.btnnoisep.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setNoiseM(2)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setNoiseM(1)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setNoiseM(1)
			else self:setNoiseM(1)
			end delay = 0
		elseif e.keyCode == KeyCode.NUM9 then -- SHIFT = page up!
			g_isuibuttondown = false
			self.tiled_ui.btnnoisem.isclicked = false
			self.tiled_ui.btnnoisep.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setNoiseP(2)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setNoiseP(1)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setNoiseP(1)
			else self:setNoiseP(1)
			end delay = 0
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
		elseif e.keyCode == KeyCode.NUM1 then -- SHIFT = arrow left!
			g_isuibuttondown = false
			self.tiled_ui.btncolorseedm.isclicked = false
			self.tiled_ui.btncolorseedp.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColorSeedM(16)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColorSeedM(2)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColorSeedM(1)
			else self:setColorSeedM(1)
			end delay = 0
		elseif e.keyCode == KeyCode.NUM3 then -- SHIFT = arrow right!
			g_isuibuttondown = false
			self.tiled_ui.btncolorseedm.isclicked = false
			self.tiled_ui.btncolorseedp.isclicked = false
			keymodifier = application:getKeyboardModifiers()
			if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColorSeedP(16)
			elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColorSeedP(2)
			elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColorSeedP(1)
			else self:setColorSeedP(1)
			end delay = 0
		end
	end)
	-- buttons
	self.tiled_ui.btnnoisem:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setNoiseM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setNoiseM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setNoiseM(1)
		else self:setNoiseM(1)
		end delay = 0
	end)
	self.tiled_ui.btnnoisep:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setNoiseP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setNoiseP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setNoiseP(1)
		else self:setNoiseP(1)
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
	self.tiled_ui.btncolorseedm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColorSeedM(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColorSeedM(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColorSeedM(1)
		else self:setColorSeedM(1)
		end delay = 0
	end)
	self.tiled_ui.btncolorseedp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setColorSeedP(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setColorSeedP(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setColorSeedP(1)
		else self:setColorSeedP(1)
		end delay = 0
	end)
	self.tiled_ui.btnfrequencym:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setFrequencyM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setFrequencyM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setFrequencyM(1)
		else self:setFrequencyM(1)
		end delay = 0
	end)
	self.tiled_ui.btnfrequencyp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setFrequencyP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setFrequencyP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setFrequencyP(1)
		else self:setFrequencyP(1)
		end delay = 0
	end)
	self.tiled_ui.btnoctavesm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOctavesM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOctavesM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOctavesM(1)
		else self:setOctavesM(1)
		end delay = 0
	end)
	self.tiled_ui.btnoctavesp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOctavesP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOctavesP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOctavesP(1)
		else self:setOctavesP(1)
		end delay = 0
	end)
	self.tiled_ui.btnlacunaritym:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setLacunarityM(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setLacunarityM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setLacunarityM(1)
		else self:setLacunarityM(1)
		end delay = 0
	end)
	self.tiled_ui.btnlacunarityp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setLacunarityP(2)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setLacunarityP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setLacunarityP(1)
		else self:setLacunarityP(1)
		end delay = 0
	end)
	self.tiled_ui.btninterpm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setInterpM(1)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setInterpM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setInterpM(1)
		else self:setInterpM(1)
		end delay = 0
	end)
	self.tiled_ui.btninterpp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setInterpP(1)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setInterpP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setInterpP(1)
		else self:setInterpP(1)
		end delay = 0
	end)
	self.tiled_ui.btnfractalgainm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setFractalGainM(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setFractalGainM(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setFractalGainM(1)
		else self:setFractalGainM(1)
		end delay = 0
	end)
	self.tiled_ui.btnfractalgainp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setFractalGainP(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setFractalGainP(2)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setFractalGainP(1)
		else self:setFractalGainP(1)
		end delay = 0
	end)
	--
	self.tiled_ui.widthm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setWidthM(128)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setWidthM(32)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setWidthM(1)
		else self:setWidthM(8)
		end delay = 0
	end)
	self.tiled_ui.widthp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setWidthP(128)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setWidthP(32)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setWidthP(1)
		else self:setWidthP(8)
		end delay = 0
	end)
	self.tiled_ui.heightm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setHeightM(128)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setHeightM(32)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setHeightM(1)
		else self:setHeightM(8)
		end delay = 0
	end)
	self.tiled_ui.heightp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setHeightP(128)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setHeightP(32)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setHeightP(1)
		else self:setHeightP(8)
		end delay = 0
	end)
	self.tiled_ui.btnoffsetxm:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOffsetXM(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOffsetXM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOffsetXM(1)
		else self:setOffsetXM(1)
		end delay = 0
	end)
	self.tiled_ui.btnoffsetxp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOffsetXP(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOffsetXP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOffsetXP(1)
		else self:setOffsetXP(1)
		end delay = 0
	end)
	self.tiled_ui.btnoffsetym:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOffsetYM(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOffsetYM(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOffsetYM(1)
		else self:setOffsetYM(1)
		end delay = 0
	end)
	self.tiled_ui.btnoffsetyp:addEventListener("clicked", function(e)
		keymodifier = application:getKeyboardModifiers()
		if keymodifier & KeyCode.MODIFIER_ALT > 0 then self:setOffsetYP(16)
		elseif keymodifier & KeyCode.MODIFIER_CTRL > 0 then self:setOffsetYP(1)
		elseif keymodifier & KeyCode.MODIFIER_SHIFT > 0 then self:setOffsetYP(1)
		else self:setOffsetYP(1)
		end delay = 0
	end)
	--
	self.tiled_ui.btncolorcount:addEventListener("clicked", function(e)
		self:setColorCount()
	end)
	self.tiled_ui.btnscalex:addEventListener("clicked", function(e)
		self:setSX()
	end)
	self.tiled_ui.btnscaley:addEventListener("clicked", function(e)
		self:setSY()
	end)
end

-- check Folders
function LevelY:checkFolders()
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
	local folder = application:get("directory", "pictures")..sep.."MazeImage"..sep.."noise"
	-- check folder: nil=doesn't exist, 1=exists
	if application:get("pathfileexists", folder) == nil then
		application:set("mkDir", folder)
	end

	return root, folder
end

-- change scene
function LevelY:gotoScene(xscene)
	mySavePrefs(g_configfilepath)
	scenemanager:changeScene(
		xscene, 1,
		transitions[math.random(1, #transitions)],
		easings[math.random(1, #easings)]
	)
end
