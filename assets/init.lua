require "scenemanager"
require "easing"
require "FastNoise"
-- globals
screenwidth, screenheight = application:get("screenSize") -- the actual user's screen size, yes!
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds()
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
-- fonts
local ttfont1path = "fonts/JetBrainsMono-Regular.ttf"
-- composite fonts
local str = "" -- "My Composite Font text"
local nf = TTFont.new(ttfont1path, 14, str) -- 16, small normal
local of = TTFont.new(ttfont1path, 14, str, false, 1) -- 16, small outline
cfs= CompositeFont.new( -- composite font small
	{
		{ font=of, color=0x0, alpha=1, }, -- draw outline in black (if you pass a color you MUST pass its alpha)
		{ font=nf, x=1, y=1, }, -- draw normal text with an offset
	}
)
nf = TTFont.new(ttfont1path, 24, str) -- 24, medium normal
of = TTFont.new(ttfont1path, 24, str, false, 1) -- 24, medium outline
cfm= CompositeFont.new( -- composite font medium
	{
		{ font=of, color=0x0, alpha=1, }, -- draw outline in black (if you pass a color you MUST pass its alpha)
		{ font=nf, x=1, y=1, }, -- draw normal text with an offset
	}
)
nf = TTFont.new(ttfont1path, 32, str) -- 32, large normal
of = TTFont.new(ttfont1path, 32, str, false, 1) -- 32, large outline
cfl= CompositeFont.new( -- composite font large
	{
		{ font=of, color=0x0, alpha=1, }, -- draw outline in black (if you pass a color you MUST pass its alpha)
		{ font=nf, x=1, y=1, }, -- draw normal text with an offset
	}
)
nf = TTFont.new(ttfont1path, 40, str) -- 36, extra large normal
of = TTFont.new(ttfont1path, 40, str, false, 1) -- 36, extra large outline
cfxl= CompositeFont.new( -- composite font xtra large
	{
		{ font=of, color=0x0, alpha=1, }, -- draw outline in black (if you pass a color you MUST pass its alpha)
		{ font=nf, x=1, y=1, }, -- draw normal text with an offset
	}
)
-- global prefs
g_configfilepath = "|D|params.txt" -- C:\Users\mokal\AppData\Local\Temp\gideros\Maze Image\documents
-- global prefs Maze Image (LevelX)
g_Xbgcolor = nil
g_Xcellcolor = nil
g_Xcellwidth = nil
g_Xcellheight = nil
g_Xcols = nil -- should be odd
g_Xrows = nil -- should be odd
g_Xseed = nil
g_Xopenend = nil -- draw maze exits? true, false
-- global prefs Noise Maze Image (LevelY)
g_Ybgcolor = nil
g_Ycolor = nil
g_Ynoise = nil
g_Yseed = nil
g_Ycolorseed = nil
g_Yfrequency = nil
g_Yoctaves = nil
g_Ylacunarity = nil
g_Yinterp = nil
g_Yfractalgain = nil
g_YoffsetX = nil
g_YoffsetY = nil
g_Ywidth = nil
g_Yheight = nil
g_Ycolorcount = nil
g_Yscalex = nil
g_Yscaley = nil

-- Noise tables
noises = {}
noises[#noises+1] = {type=Noise.CELLULAR, name="CELLULAR"}
noises[#noises+1] = {type=Noise.BILLOW, name="BILLOW"}
noises[#noises+1] = {type=Noise.FBM, name="FBM"}
noises[#noises+1] = {type=Noise.PERLIN, name="PERLIN"}
noises[#noises+1] = {type=Noise.PERLIN_FRACTAL, name="PERLIN FRACTAL"}
noises[#noises+1] = {type=Noise.RIGID_MULTI, name="RIGID MULTI"}
noises[#noises+1] = {type=Noise.SIMPLEX, name="SIMPLEX"}
noises[#noises+1] = {type=Noise.SIMPLEX_FRACTAL, name="SIMPLEX FRACTAL"}
noises[#noises+1] = {type=Noise.VALUE, name="VALUE"}
noises[#noises+1] = {type=Noise.VALUE_FRACTAL, name="VALUE FRACTAL"}
noises[#noises+1] = {type=Noise.CELL_VALUE, name="CELL VALUE"}
noises[#noises+1] = {type=Noise.CUBIC, name="CUBIC"}
noises[#noises+1] = {type=Noise.CUBIC_FRACTAL, name="CUBIC FRACTAL"}
noises[#noises+1] = {type=Noise.DISTANCE, name="DISTANCE"}
noises[#noises+1] = {type=Noise.DISTANCE_2, name="DISTANCE 2"}
noises[#noises+1] = {type=Noise.DISTANCE_2_ADD, name="DISTANCE 2 ADD"}
noises[#noises+1] = {type=Noise.DISTANCE_2_DIV, name="DISTANCE 2 DIV"}
noises[#noises+1] = {type=Noise.DISTANCE_2_MUL, name="DISTANCE 2 MUL"}
noises[#noises+1] = {type=Noise.DISTANCE_2_SUB, name="DISTANCE 2 SUB"}
noises[#noises+1] = {type=Noise.EUCLIDEAN, name="EUCLIDEAN"}
noises[#noises+1] = {type=Noise.HERMITE, name="HERMITE"}
noises[#noises+1] = {type=Noise.LINEAR, name="LINEAR"}
noises[#noises+1] = {type=Noise.MANHATTAN, name="MANHATTAN"}
noises[#noises+1] = {type=Noise.NATURAL, name="NATURAL"}
noises[#noises+1] = {type=Noise.NOISE_LOOKUP, name="NOISE LOOKUP"}
noises[#noises+1] = {type=Noise.QUINTIC, name="QUINTIC"}
noises[#noises+1] = {type=Noise.WHITE_NOISE, name="WHITE NOISE"}

interps = {}
interps[#interps+1] = {type=Noise.LINEAR, name="LINEAR"}
interps[#interps+1] = {type=Noise.HERMITE, name="HERMITE"}
interps[#interps+1] = {type=Noise.QUINTIC, name="QUINTIC"}
