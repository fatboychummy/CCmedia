--[[FATFILE
1
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/FatBoyUpdateHandler.lua
]]

if not fs.exists("/FatFileSystem.lua") then
  error("FatFileSystem.lua was not found in the root directory.", -1)
else
  print("FatFileSystem is in the root directory.")
end

local fileSystem = dofile("FatFileSystem.lua")
local fe = fileSystem.betterFind("FatErrors.lua")
if #fe == 1 then
  print("FatErrors exists.")
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


local function updateFile(fileInfo)
  bassert(type(fileInfo) == "table", 2, "updateFile", 1, "table", fileInfo)

  local version = false

  if fileInfo["version"] then
    version = fileInfo.version
  else
    return false, "Missing version information."
  end
  if fileInfo["location"] then
    if fileInfo["file"] then
      local h = http.get(fileInfo.location)
      local open = h.readLine()
      local verLine = h.readLine()
      local ver = tonumber(verLine)
      if version < ver then
        if h then
          local h2 = fs.open(fileInfo.file, "w")
          if h2 then
            h.writeLine(open)
            h.writeLine(verLine)
            h2.write(h.readAll())
            h.close()
            h2.close()
            return true
          else
            h.close()
            return false, "Failed to open file for writing ("
              .. tostring(fileInfo.file) .. ")."
          end
        else
          return false, "Failed to open http handle ( "
            .. tostring(fileInfo.location) .. ") for file \""
            .. tostring(fileInfo.file) .. "\"."
        end
      else
        h.close()
      end
    else
      return false, "Missing file location."
    end
  else
    return false, "Missing http location information."
  end
  return false, "An unknown thing has occured.  This shouldn't happen."
end

local function updateAllFATS()
  local FATS = fileSystem.getFATS()
  for i = 1, #FATS do
    local ok, err = updateFile(FATS[i])
    if not ok then
      printError(err)
    end
  end
end

return {
  updateAllFATS = updateAllFATS,
  updateFile = updateFile
}