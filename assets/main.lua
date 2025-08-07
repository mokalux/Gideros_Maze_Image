--https://auburn.github.io/FastNoiseLite/
-- app
if not application:isPlayerMode() then
	local appname = "Maze Image v1.2.0"
	print(
		" __  __                 _____                            ".."\n"..
		"|  \\/  |               |_   _|                           ".."\n"..
		"| \\  / | __ _ _______    | |  _ __ ___   __ _  __ _  ___ ".."\n"..
		"| |\\/| |/ _` |_  / _ \\   | | | '_ ` _ \\ / _` |/ _` |/ _ \\".."\n"..
		"| |  | | (_| |/ /  __/  _| |_| | | | | | (_| | (_| |  __/".."\n"..
		"|_|  |_|\\__,_/___\\___| |_____|_| |_| |_|\\__,_|\\__, |\\___|".."\n"..
		"                                               __/ |     ".."\n"..
		"                                              |___/      ".."\n"
	)
--	application:set("windowModel", "noMaximize")
	application:set("windowPosition", (screenwidth - myappwidth)/2 + 16, (screenheight - myappheight)/2 - 16)
	application:set("windowTitle", appname)
--	application:set("windowColor", 0, 0, 0)
--	application:set("minimumSize", myappwidth/2, myappheight/2)
--	application:set("maximumSize", myappwidth, myappheight)
end
-- prefs
function myLoadPrefs(xconfigfilepath)
	local _result, mydata = getData(xconfigfilepath) -- try to read information from file
--	local mydata = {} -- when I want to purge the table for testing
	if not mydata then -- if no prefs file, create it
		mydata = {}
		-- levelX
		mydata.g_Xbgcolor = g_Xbgcolor
		mydata.g_Xcellcolor = g_Xcellcolor
		mydata.g_Xcellwidth = g_Xcellwidth
		mydata.g_Xcellheight = g_Xcellheight
		mydata.g_Xcols = g_Xcols
		mydata.g_Xrows = g_Xrows
		mydata.g_Xseed = g_Xseed
		mydata.g_Xopenend = g_Xopenend
		-- levelY
		mydata.g_Ybgcolor = g_Ybgcolor
		mydata.g_Ycolor = g_Ycolor
		mydata.g_Ynoise = g_Ynoise
		mydata.g_Yseed = g_Yseed
		mydata.g_Ycolorseed = g_Ycolorseed
		mydata.g_Yfrequency = g_Yfrequency
		mydata.g_Yoctaves = g_Yoctaves
		mydata.g_Ylacunarity = g_Ylacunarity
		mydata.g_Yinterp = g_Yinterp
		mydata.g_Yfractalgain = g_Yfractalgain
		mydata.g_YoffsetX = g_YoffsetX
		mydata.g_YoffsetY = g_YoffsetY
		mydata.g_Ywidth = g_Ywidth
		mydata.g_Yheight = g_Yheight
		mydata.g_Ycolorcount = g_Ycolorcount
		mydata.g_Yscalex = g_Yscalex
		mydata.g_Yscaley = g_Yscaley
		-- save prefs
		saveData(g_configfilepath, mydata) -- create file and save datas
	else
		-- levelX
		g_Xbgcolor = mydata.g_Xbgcolor
		g_Xcellcolor = mydata.g_Xcellcolor
		g_Xcellwidth = mydata.g_Xcellwidth
		g_Xcellheight = mydata.g_Xcellheight
		g_Xcols = mydata.g_Xcols
		g_Xrows = mydata.g_Xrows
		g_Xseed = mydata.g_Xseed
		g_Xopenend = mydata.g_Xopenend
		-- levelY
		g_Ybgcolor = mydata.g_Ybgcolor
		g_Ycolor = mydata.g_Ycolor
		g_Ynoise = mydata.g_Ynoise
		g_Yseed = mydata.g_Yseed
		g_Ycolorseed = mydata.g_Ycolorseed
		g_Yfrequency = mydata.g_Yfrequency
		g_Yoctaves = mydata.g_Yoctaves
		g_Ylacunarity = mydata.g_Ylacunarity
		g_Yinterp = mydata.g_Yinterp
		g_Yfractalgain = mydata.g_Yfractalgain
		g_YoffsetX = mydata.g_YoffsetX
		g_YoffsetY = mydata.g_YoffsetY
		g_Ywidth = mydata.g_Ywidth
		g_Yheight = mydata.g_Yheight
		g_Ycolorcount = mydata.g_Ycolorcount
		g_Yscalex = mydata.g_Yscalex
		g_Yscaley = mydata.g_Yscaley
	end
end
-- save prefs
function mySavePrefs(xconfigfilepath)
	local mydata = {} -- clear the table
	-- levelX
	mydata.g_Xbgcolor = g_Xbgcolor
	mydata.g_Xcellcolor = g_Xcellcolor
	mydata.g_Xcellwidth = g_Xcellwidth
	mydata.g_Xcellheight = g_Xcellheight
	mydata.g_Xcols = g_Xcols
	mydata.g_Xrows = g_Xrows
	mydata.g_Xseed = g_Xseed
	mydata.g_Xopenend = g_Xopenend
	-- levelY
	mydata.g_Ybgcolor = g_Ybgcolor
	mydata.g_Ycolor = g_Ycolor
	mydata.g_Ynoise = g_Ynoise
	mydata.g_Yseed = g_Yseed
	mydata.g_Ycolorseed = g_Ycolorseed
	mydata.g_Yfrequency = g_Yfrequency
	mydata.g_Yoctaves = g_Yoctaves
	mydata.g_Ylacunarity = g_Ylacunarity
	mydata.g_Yinterp = g_Yinterp
	mydata.g_Yfractalgain = g_Yfractalgain
	mydata.g_YoffsetX = g_YoffsetX
	mydata.g_YoffsetY = g_YoffsetY
	mydata.g_Ywidth = g_Ywidth
	mydata.g_Yheight = g_Yheight
	mydata.g_Ycolorcount = g_Ycolorcount
	mydata.g_Yscalex = g_Yscalex
	mydata.g_Yscaley = g_Yscaley
	-- save prefs
	saveData(xconfigfilepath, mydata) -- save new datas
end
-- let's load initial prefs
myLoadPrefs(g_configfilepath) -- load prefs

-- scene manager
scenemanager = SceneManager.new(
	{
		["menu"] = Menu,
		["levelX"] = LevelX, -- maze image
		["levelY"] = LevelY, -- noise maze image
	}
)
stage:addChild(scenemanager)
scenemanager:changeScene("menu")
-- global tables
transitions = {
	SceneManager.moveFromRight, -- 1
	SceneManager.moveFromLeft, -- 2
	SceneManager.moveFromBottom, -- 3
	SceneManager.moveFromTop, -- 4
	SceneManager.moveFromRightWithFade, -- 5
	SceneManager.moveFromLeftWithFade, -- 6
	SceneManager.moveFromBottomWithFade, -- 7
	SceneManager.moveFromTopWithFade, -- 8
	SceneManager.overFromRight, -- 9
	SceneManager.overFromLeft, -- 10
	SceneManager.overFromBottom, -- 11
	SceneManager.overFromTop, -- 12
	SceneManager.overFromRightWithFade, -- 13
	SceneManager.overFromLeftWithFade, -- 14
	SceneManager.overFromBottomWithFade, -- 15
	SceneManager.overFromTopWithFade, -- 16
	SceneManager.fade, -- 17
	SceneManager.crossFade, -- 18
	SceneManager.flip, -- 19
	SceneManager.flipWithFade, -- 20
	SceneManager.flipWithShade, -- 21
}
easings = {
	easing.inBack, -- 1
	easing.outBack, -- 2
	easing.inOutBack, -- 3
	easing.inBounce, -- 4
	easing.outBounce, -- 5
	easing.inOutBounce, -- 6
	easing.inCircular, -- 7
	easing.outCircular, -- 8
	easing.inOutCircular, -- 9
	easing.inCubic, -- 10
	easing.outCubic, -- 11
	easing.inOutCubic, -- 12
	easing.inElastic, -- 13
	easing.outElastic, -- 14
	easing.inOutElastic, -- 15
	easing.inExponential, -- 16
	easing.outExponential, -- 17
	easing.inOutExponential, -- 18
	easing.linear, -- 19
	easing.inQuadratic, -- 20
	easing.outQuadratic, -- 21
	easing.inOutQuadratic, -- 22
	easing.inQuartic, -- 23
	easing.outQuartic, -- 24
	easing.inOutQuartic, -- 25
	easing.inQuintic, -- 26
	easing.outQuintic, -- 27
	easing.inOutQuintic, -- 28
	easing.inSine, -- 29
	easing.outSine, -- 30
	easing.inOutSine, -- 31
}
