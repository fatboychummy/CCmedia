--[[FATFILE
1
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/helpfulthings/FatTerm.lua
]]

if not fs.exists("/FatFileSystem.lua") then
  error("FatFileSystem.lua was not found in the root directory.", -1)
end

local fileSystem = dofile("/FatFileSystem.lua")
local fe = fileSystem.betterFind("FatErrors.lua")
if #fe == 1 then
  fe = fe[1]
  fe = dofile(fe)
elseif #fe > 1 then
  error("Multiple copies of FatErrors.lua exist!")
else
  error("FatErrors.lua does not exist anywhere!")
end

local bassert = fe.bassert
local er = fe.er
fe = nil

--[[
@long Writes a string of text,
then jumps to the next line directly beneath the start location.
@params
  text: text to write
@return
  nil
]]
function term.writeReturn(text)
  local x, y = term.getCursorPos()
  print(text)
  term.setCursorPos(x, y + 1)
end


--[[
@short draws a box from (x1, y1) to (x2, y2) with optional color.
@params
  x1: left-most location
  x2: right-most location
  y1: top-most location
  y2: bottom-most location
  *c: color to be used
  *assure: if true, will skip checking arguments for errors (less cpu usage)
@return
  nil
]]
function term.drawBox(x1, y1, x2, y2, c, assure)
  -- if assure is supplied, we will skip all the checks because we can
  -- "assure" that there are no errors.
  if not assure then
    bassert(type(x1) == "number", 2,  1, 1, "number", x1)

    bassert(type(y1) == "number", 2, 1, 2, "number", y1)

    bassert(type(x2) == "number", 2, 1, 3,  "number", x2)
    bassert(x2 >= x1, 2 ,-1, "Bad argument #1 and #3, "
          .. "expected (argument #1) >= (argument #3).")

    bassert(type(y2) == "number", 2, 1, 4, "number", y2)
    bassert(y2 >= y1, 2, -1, "Bad argument #2 and #4, "
          .. "expected (argument #2) >= (argument #4).")

    -- color
    bassert(type(c) == "number" or type(c) == "nil", 2, -1,
          "Bad argument #5, expected number or nil, got " .. type(c))
  end

  local old = term.getBackgroundColor()

  term.setBackgroundColor(c or colors.black)

  for i = y1, y2 do
    term.setCursorPos(x1, i)
    term.write(string.rep(" ", x2 - x1 + 1))
  end

  term.setBackgroundColor(old)
end
