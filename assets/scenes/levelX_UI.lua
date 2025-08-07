LevelX_UI = Core.class(Sprite)

function LevelX_UI:init(xuitiledpath, xUIlayer)
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
						g_Xcellcolor = e.color
						mySavePrefs(g_configfilepath)
					end)
				elseif object.name == "RESET_MAZE_POS" then
					self.btnresetmazepos = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
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
				if object.name == "OPENEND" then
					self.btnopenend = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"ENDS", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "CELL_W" then
					self.cellwidthv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "CELL_W-" then
					self.btncellwidthm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "CELL_W+" then
					self.btncellwidthp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "CELL_W_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "CELL_H" then
					self.cellheightv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "CELL_H-" then
					self.btncellheightm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "CELL_H+" then
					self.btncellheightp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "CELL_H_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				-- MAZE
				--function LevelX_UI:TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
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
				elseif object.name == "COLS" then
					self.numofcolsv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "COL-" then
					self.numofcolsm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "COL+" then
					self.numofcolsp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "NUM_COL_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				elseif object.name == "ROWS" then
					self.numofrowsv = self:TF(object.x, object.y + object.height, sttfV, "xxx", xUIlayer, 0, tfcolorV)
				elseif object.name == "ROW-" then
					self.numofrowsm = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"-", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "ROW+" then
					self.numofrowsp = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"+", xUIlayer, tfcolorB, sttfB)
				elseif object.name == "NUM_ROW_TEXT" then
					self:TF(object.x, object.y + object.height, sttf, object.text, xUIlayer, 0, tfcolor)
				-- SAVE
				elseif object.name == "SAVE" then
					self.btnsave = self:BTNTXT(object.x + object.width / 2, object.y + object.height / 2, object.width, object.height,
						"EXPORT", xUIlayer, tfcolorB, sttfB)
				-- error
				else print("ERROR LAYER", layer.name, object.name) end
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
				--TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
				--BTNTXT(xposx, xposy, xwidth, xheight, xtext, xparent, xtextcolorup, xttf)
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
function LevelX_UI:TF(xposx, xposy, xttf, xtext, xparent, xhack, xcolor, xalpha)
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
function LevelX_UI:BTNTXT(xposx, xposy, xwidth, xheight, xtext, xparent, xtextcolorup, xttf)
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
function LevelX_UI:BTNIMG(xposx, xposy, xwidth, xheight, ximg, xparent)
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
