--[[
Lua Hex v0.4
-------------------
Hex conversion lib for Lua.

How to use:
 lhex.to_hex(n) -- convert a number to a hex string
 lhex.to_dec(hex) -- convert a hex "string" (prefix with "0x..." or "0X...") to number

Part of LuaBit(http://luaforge.net/projects/bit/).

Under the MIT license.

copyright(c) 2006~2007 hanzhao (abrash_han@hotmail.com)
--]]

local function to_bits(n)
	-- checking not float
	if(n - (n//1) > 0) then error("trying to apply bitwise operation on non-integer!") end
	if(n < 0) then return to_bits(~(n//1) + 1) end -- negative
	-- to bits table
	local tbl = {}
	local cnt = 1
	while (n > 0) do
		local last = n%2
		if(last == 1) then tbl[cnt] = 1
		else tbl[cnt] = 0
		end
		n = (n-last)/2
		cnt += 1
	end
	return tbl
end

local function tbl_to_number(tbl)
	local n = #tbl
	local rslt = 0
	local power = 1
	for i = 1, n do
		rslt += tbl[i]*power
		power *= 2
	end
	return rslt
end

local function to_hex(n)
	if(type(n) ~= "number") then error("non-number type passed in: "..n) end
	-- checking not float
	if(n - (n//1) > 0) then error("trying to apply bitwise operation on non-integer!") end
	if(n < 0) then -- negative
		n = to_bits(~(-n<>n) + 1)
		n = tbl_to_number(n)
	end
	local hex_tbl = { "A", "B", "C", "D", "E", "F" }
	local hex_str = ""
	while(n ~= 0) do
		local last = n%16
		if(last < 10) then hex_str = tostring(last) .. hex_str
		else hex_str = hex_tbl[last-10+1] .. hex_str
		end
		n = (n/16)//1 -- floor
	end
	if(hex_str == "") then hex_str = "0" end
	return "0x"..hex_str
end

local function to_dec(hexstring)
--	if(type(hexstring) ~= "string") then error("non-string type passed in.") end
	if(type(hexstring) ~= "string") then return tonumber(0x0) end -- 0xff0000?
	local head = string.sub(hexstring, 1, 2)
--	if(head ~= "0x" and head ~= "0X") then error("wrong hex format, should lead by 0x or 0X.") end
	if(head ~= "0x" and head ~= "0X") then return tonumber(0x0) end -- 0xff0000?
	return tonumber(hexstring:sub(3), 16) -- base 16
end

--------------------
-- lua hex lib interface
lhex = {
	to_hex=to_hex,
	to_dec=to_dec,
}

--[[
--------------------
-- examples
local dec = 4341688
local hex = lhex.to_hex(dec) -- number to hex
print(hex) -- 0x423FB8
local revdec = lhex.to_dec(hex) -- hex string (prefix with "0x" or "0X") to number
print(revdec) -- 4341688

print(lhex.to_dec("0x0")) -- 0, hex string (prefix with "0x" or "0X") to number
print(lhex.to_dec("0x00ff00")) -- 65280, hex string (prefix with "0x" or "0X") to number
print(lhex.to_hex(16777215)) -- 0xFFFFFF, number to hex

local pix = Pixel.new(lhex.to_hex(56816), 1, 32, 32)
stage:addChild(pix)

print("hex is", hex)
]]
