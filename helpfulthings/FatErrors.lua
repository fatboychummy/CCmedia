--[[FATFILE
3
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/helpfulthings/FatErrors.lua
]]

-- Error handling functions
local function er(reason, ...)
  local ex = {...}
  local str = ""

  if reason == 0 then
      -- "Function: Bad argument #1. Expected inventory, got <some type>"
    local sSelf = ex[1]
    local arg = ex[2]
    str = str .. "Bad argument #1"
      .. ". Expected inventory, got "
    if type(sSelf) == "table" then
      if sSelf["_type"] and sSelf["_type"] then
        str = str .. tostring(sSelf._type)
      else
        str = str .. "table"
      end
    else
      str = str .. type(sSelf)
    end
    str = str .. "."
  elseif reason == 1 then
      -- "Function: Bad argument #<arg>. Expected <type>, got <someOtherType>"
    str = str .. "Bad argument #" .. tostring(ex[1]) .. ". Expected "
      .. tostring(ex[2]) .. ", got " .. type(ex[3]) .. "."
  elseif reason == 2 then
      -- "Function: Bad argument #<arg>.
      -- Expected name of peripheral (got <name>)"
    str = str .. "Bad argument #" .. tostring(ex[1])
      .. ". Expected name of peripheral (got " .. ex[2] .. ")."
  elseif reason == -1 then
      -- "Function: <error>"
    str = str .. ex[1]
  else
      -- "Function: An unexpected error occured."
    str = str .. "An unexpected error occured."
  end
  return str
end

local function bassert(assertion, level, func, reason, ...)
  if not assertion then
    error(er(func, reason, ...), level + 1)
    -- error with the error level raised by one (since this function was called)
    -- by the assertion
  end
end
----

return {
  bassert = bassert,
  er = er
}
