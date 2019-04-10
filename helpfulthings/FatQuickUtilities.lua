--[[FATFILE
2
https://github.com/fatboychummy/CCmedia/blob/master/helpfulthings/FatQuickUtilities.lua
]]

local function deepCopy(a)
  local b = {}

  for k, v in pairs(a) do
    if type(v) == "table" then
      b[k] = deepCopy(v)
    else
      b[k] = v
    end
  end

  return b
end
