LevelY_UI = Core.class(Sprite)

function LevelY_UI:init(xuitiledpath, xUIlayer)
	-- load the tiled ui
	local tiled_ui = loadfile(xuitiledpath)()
	-- theme
	local tfcolor = 0xffffff -- 0xaaaaff, textfields
	local tfcolorV = 0xe8e8e8 -- 0x00aaff, values
	local tfcolorB = 0xdadada -- 0xffff77, buttons
	local tfcolorSC = 0xc4c4c4 -- 0x55ffff, shortcuts
	local tfcolorI = 0xffff7f -- 0x55ffff, infos
	-- size
	local sttf = cfm -- textfields
	local sttfV = cfm -- values
	local sttfB = cfm -- buttons
	local sttfSC = cfs -- shortcuts
	local sttfI = cfm -- infos
	-- parse the tiled level
	local layers = tiled_ui.layers
	for i = 1, #layers do
		local layer = layers[i]
		-- MENU
		-- *************
		if layer.name == "menu" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- ojects
				--TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
				--BTNTXT(xposx, xposy, xwidth, xheight, xtext, xparent, xtextcolorup, xttf)
				if object.name == "COLOR_PICKER" then
					self.colorPicker = ColorPicker.new(object.width, object.height)
					self.colorPicker:setPosition(object.x, object.y)
					xUIlayer:addChild(self.colorPicker)
					self.colorPicker:addEventListener("COLOR_CHANGED",function(e)
						-- save prefs
						g_Ybgcolor = e.color
						mySavePrefs(g_configfilepath)
					end)
				elseif object.name == "RESET_POS" then
					self.btnresetpos = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"R", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "EXIT" then
					self.btnexit = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"BACK", xUIlayer, tfcolorB, sttfB)
				-- error
				else print("ERROR LAYER", layer.name, object.name) end
			end
		-- PARAMETERS
		-- *************
		elseif layer.name == "params" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				--TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
				--BTNTXT(xposx, xposy, xwidth, xheight, xtext, xparent, xtextcolorup, xttf)
				-- CELLS
				if object.name == "NOISE" then
					self.noisev = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "NOISE-" then
					self.btnnoisem = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "NOISE+" then
					self.btnnoisep = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "NOISE_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "RANDOM_SEED" then
					self.btnrandomseed = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"Rand", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "SEED" then
					self.seedv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "SEED-" then
					self.btnseedm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "SEED+" then
					self.btnseedp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "SEED_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)





				elseif object.name == "COLORCOUNT" then
					self.btncolorcount = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"x", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "RANDOM_COLORSEED" then
					self.btnrandomcolorseed = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"Rand", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "COLORSEED" then
					self.colorseedv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "COLORSEED-" then
					self.btncolorseedm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "COLORSEED+" then
					self.btncolorseedp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "COLORSEED_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)






				elseif object.name == "FREQUENCY" then
					self.frequencyv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "FREQUENCY-" then
					self.btnfrequencym = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "FREQUENCY+" then
					self.btnfrequencyp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "FREQUENCY_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "OCTAVES" then
					self.octavesv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "OCTAVES-" then
					self.btnoctavesm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OCTAVES+" then
					self.btnoctavesp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OCTAVES_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "LACUNARITY" then
					self.lacunarityv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "LACUNARITY-" then
					self.btnlacunaritym = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "LACUNARITY+" then
					self.btnlacunarityp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "LACUNARITY_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "INTERP" then
					self.interpv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "INTERP-" then
					self.btninterpm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "INTERP+" then
					self.btninterpp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "INTERP_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "FRACTALGAIN" then
					self.fractalgainv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "FRACTALGAIN-" then
					self.btnfractalgainm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "FRACTALGAIN+" then
					self.btnfractalgainp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "FRACTALGAIN_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "OFFSETX" then
					self.offsetxv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "OFFSETX-" then
					self.btnoffsetxm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OFFSETX+" then
					self.btnoffsetxp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OFFSETX_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "OFFSETY" then
					self.offsetyv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "OFFSETY-" then
					self.btnoffsetym = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OFFSETY+" then
					self.btnoffsetyp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "OFFSETY_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				-- MAZE
				--function LevelY_UI:TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
				elseif object.name == "WIDTH" then
					self.widthv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "WIDTH-" then
					self.widthm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "WIDTH+" then
					self.widthp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "WIDTH_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "HEIGHT" then
					self.heightv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "HEIGHT-" then
					self.heightm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "HEIGHT+" then
					self.heightp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "HEIGHT_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "SCALEX" then
					self.btnscalex = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"x", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "SCALEY" then
					self.btnscaley = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"x", xUIlayer, tfcolorB, sttfB)
				-- EXPORT
				elseif object.name == "EXPORT" then
					self.btnsave = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"EXPORT", xUIlayer, tfcolorI, sttfB) -- tfcolorB
				-- error
				else print("ERROR LAYER", layer.name, object.name) end
			end
		-- RESET BUTTONS
		-- *************
		elseif layer.name == "resets" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- ojects
				if object.name:match("reset$") then
--					print(object.name)
					self[object.name] = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"r", xUIlayer, tfcolorB, sttfB)
				end
			end
		-- SHORTCUTS
		-- *************
		elseif layer.name == "shortcuts" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				if object.name:match("SC$") then
					self:TF(object.x, object.y + object.height, sttfSC, object.text, xUIlayer, 3, tfcolorSC)
				end
			end
		-- INFOS
		-- *************
		elseif layer.name == "infos" then
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- ojects
				if object.name == "info1" then self.tfinfo1 = self:TF(object.x, object.y, sttfI, "", xUIlayer, 0, tfcolorI)
				elseif object.name == "info2" then self.tfinfo2 = self:TF(object.x, object.y, sttfI, "", xUIlayer, 0, tfcolorI)
				elseif object.name == "info3" then self.tfinfo3 = self:TF(object.x, object.y, sttfI, "", xUIlayer, 0, tfcolorI)
				-- error
				else print("ERROR LAYER", layer.name, object.name)
				end
			end
		-- WHAT?!
		-- ******
		else print("WHAT?!", layer.name) end -- warning didn't process a layer?
	end
end

-- *** TF ***
function LevelY_UI:TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
	if not xhack then xhack = 0 end
	local tf = TextField.new(xttf, xtext)
	if xhack == 1 then tf:setAnchorPoint(0.5, -0.5) -- centered
	elseif xhack == 2 then tf:setAnchorPoint(0.5, -0.25)
	elseif xhack == 3 then tf:setAnchorPoint(0, 1)
	else tf:setAnchorPoint(0, 0) -- normal
	end
	tf:setPosition(xposx, xposy)
	tf:setTextColor(xcolor)
	tf:setAlpha(xalpha or 1)
	xparent:addChild(tf)
	return tf
end

-- *** BTNTXT ***
function LevelY_UI:BTNTXT(xposx, xposy, xwidth, xheight, xtext, xparent, xtextcolorup, xttf)
	local btn = ButtonTextP9UDDT.new({
		pixelcolorup=0x284979, pixelcolordown=0x4195F9, pixelalpha=0.5,
		text=xtext, ttf=xttf, textalpha=0.9,
		textcolorup=xtextcolorup or 0xffffff, textcolordown=0xeeeeee,
		isautoscale=false,
		width=xwidth, height=xheight,
		catcherx=12, catchery=12,
	})
	btn:setPosition(xposx, xposy)
	xparent:addChild(btn)
	return btn
end

-- *** BTNIMG ***
function LevelY_UI:BTNIMG(xposx, xposy, xwidth, xheight, ximg, xparent)
	local btn = ButtonTextP9UDDT.new({
		imgup=ximg,
		width=96, height=96,
	})
	btn:setAnchorPoint(-0.25, -0.25)
	btn:setScale(0.7, 0.7)
	btn:setPosition(xposx, xposy)
	btn:setColorTransform(255/255, 200/255, 200/255, 2) -- fx because btn images are white!
	xparent:addChild(btn)
	return btn
end
