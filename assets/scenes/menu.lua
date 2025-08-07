Menu = Core.class(Sprite)

function Menu:init()
	-- background
	application:setBackgroundColor(0x227178)
	local bmp = Bitmap.new(Texture.new("gfx/noise_768_512_20250805_063849.png", true))
	bmp:setAnchorPoint(0.5, 0.5)
	bmp:setAlpha(0.5)
	bmp:setScale(3)
	bmp:setRotation(-20)
	local bmp2 = Bitmap.new(Texture.new("gfx/maze_35_17_20250804_040220.png", true))
	bmp2:setAnchorPoint(0.5, 0.5)
	bmp2:setAlpha(0.5)
	bmp2:setScale(2)
	bmp2:setRotation(20)
	-- app title
	local pcu = 0x284979
	local pcd = 0x4195F9
	local tcu = 0xffffff
	local tcd = 0x000000
	local apptitle = ButtonTextP9UDDT.new({
		isautoscale=true,
		pixelcolorup=pcu, pixelalpha=0.5,
		text="MAZE IMAGE", ttf=cfxl, textcolorup=tcu,
	}, 0)
	local apptitle2 = ButtonTextP9UDDT.new({
		text="+NOISE", ttf=cfxl, textcolorup=0xff00ff, pixelalpha=0.5,
		catcherx=0,
	}, 0)
	apptitle2:setRotation(-15)
	-- copyrights
	local logo = TextField.new(cfl, "mokatunprod 2025 (c)")
	logo:setTextColor(0xffffff)
	-- buttons
	local btnMaze = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=320, height=320,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="MAZE", ttf=cfxl, textcolorup=tcu, textcolordown=tcd,
	}, 1)
	local mazesc = TextField.new(cfl, "NUM 1")
	mazesc:setTextColor(0xc4c4c4)
	local btnNoiseMaze = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=320, height=320,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="NOISE\n\n  MAZE", ttf=cfxl, textcolorup=tcu, textcolordown=tcd,
	}, 2)
	local noisemazesc = TextField.new(cfl, "NUM 2")
	noisemazesc:setTextColor(0xc4c4c4)
	local btnMazeReset = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=90, height=40,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="RESET", ttf=cfl, textcolorup=tcu, textcolordown=tcd,
		catcherx=8,
	}, 3)
	local btnNoiseMazeReset = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=90, height=40,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="RESET", ttf=cfl, textcolorup=tcu, textcolordown=tcd,
		catcherx=8,
	}, 4)
	--
	local btnSee = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=90, height=40,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="SEE", ttf=cfl, textcolorup=tcu, textcolordown=tcd,
		catcherx=8,
	}, 50)
	--
	local btnQuit = ButtonTextP9UDDT.new({
		isautoscale=false,
		width=90, height=40,
		pixelcolorup=pcu, pixelcolordown=pcd,
		text="QUIT", ttf=cfl, textcolorup=tcu, textcolordown=tcd,
		catcherx=8,
	}, 100)
	-- position
	logo:setPosition(2, myappheight - 8)
	bmp:setPosition(8*myappwidth/16, 8*myappheight/16)
	bmp2:setPosition(8*myappwidth/16, 8*myappheight/16)
	apptitle:setPosition(8*myappwidth/16, 2.5*myappheight/16)
	apptitle2:setPosition(10*myappwidth/16, 3*myappheight/16)
	btnMaze:setPosition(5*myappwidth/16, 8.5*myappheight/16)
	mazesc:setPosition(3.2*myappwidth/16, 11.75*myappheight/16)
	btnNoiseMaze:setPosition(11*myappwidth/16, 8.5*myappheight/16)
	noisemazesc:setPosition(9.2*myappwidth/16, 11.75*myappheight/16)
	btnMazeReset:setPosition(5*myappwidth/16, 13.7*myappheight/16)
	btnNoiseMazeReset:setPosition(11*myappwidth/16, 13.7*myappheight/16)
	btnSee:setPosition(8*myappwidth/16, 13.5*myappheight/16)
	btnQuit:setPosition(15.2*myappwidth/16, 0.8*myappheight/16)
	-- order
	self:addChild(bmp)
	self:addChild(bmp2)
	self:addChild(logo)
	self:addChild(apptitle2)
	self:addChild(apptitle)
	self:addChild(btnMaze)
	self:addChild(mazesc)
	self:addChild(btnNoiseMaze)
	self:addChild(noisemazesc)
	self:addChild(btnMazeReset)
	self:addChild(btnNoiseMazeReset)
	self:addChild(btnSee)
	self:addChild(btnQuit)
	-- btns listeners
	btnMaze:addEventListener("clicked", function()
		self:gotoScene("levelX")
	end)
	btnNoiseMaze:addEventListener("clicked", function()
		self:gotoScene("levelY")
	end)
	btnMazeReset:addEventListener("clicked", function()
	end)
	btnNoiseMazeReset:addEventListener("clicked", function()
	end)
	-- see
	btnSee:addEventListener("clicked", function()
		mySavePrefs(g_configfilepath)
		if application:getDeviceInfo() ~= "Web" then
			-- check folders exist
			local root, _ = self:checkFolders()
			-- go dir
			os.execute("start "..root)
		end
	end)
	-- quit
	btnQuit:addEventListener("clicked", function()
		if not application:isPlayerMode() then application:exit() end
	end)
	-- LISTENERS
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function Menu:onEnterFrame(e) end

-- EVENT LISTENERS
function Menu:onTransitionInBegin() end
function Menu:onTransitionInEnd()
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:myKeysPressed()
end
function Menu:onTransitionOutBegin()
--	self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	self:removeAllListeners()
end
function Menu:onTransitionOutEnd() end

-- KEYS HANDLER
function Menu:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if e.keyCode == KeyCode.NUM1 then self:gotoScene("levelX")
		elseif e.keyCode == KeyCode.NUM2 then self:gotoScene("levelY")
		end
	end)
end

-- check Folders
function Menu:checkFolders()
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
function Menu:gotoScene(xscene)
	scenemanager:changeScene(
		xscene, 1,
		transitions[math.random(1, #transitions)],
		easings[math.random(1, #easings)]
	)
end
