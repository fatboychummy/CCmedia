--[[FATFILE
7
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/helpfulthings/FatFileUpdateHandler.lua
]]

local needLoad = false

local fe

if needLoad then
  if not fs.exists("/FatFileSystem.lua") then
    error("FatFileSystem.lua was not found in the root directory.", -1)
  end

  local fileSystem = dofile("/FatFileSystem.lua")
  fe = fileSystem.betterFind("FatErrors.lua")
  if #fe == 1 then
    fe = fe[1]
    fe = dofile(fe)
  elseif #fe > 1 then
    error("Multiple copies of FatErrors.lua exist!")
  else
    error("FatErrors.lua does not exist anywhere!")
  end
end

local bassert = type(fe) == "table" and type(fe.bassert) == "function" and fe.bassert
              or function(a, ...) if not a then error(table.concat({...}, " "), 3) end end
fe = nil

local function updateCheck(fileInfo)
  bassert(type(fileInfo) == "table", 2, "updateFile", 1, "table", fileInfo)

  local version = false

  if fileInfo["version"] then
    version = fileInfo.version
  else
    return false, "Missing version information."
  end
  if fileInfo["location"] then
    local h = http.get(fileInfo.location)
    if h then
      local open = h.readLine()
      local verLine = h.readLine()
      local ver = tonumber(verLine)
      h.close()
      if version < ver then
        return true
      end
    else
      return false, "Failed to open http handle ( "
        .. tostring(fileInfo.location) .. ") for file \""
        .. tostring(fileInfo.file) .. "\". (update-check)"
    end
  else
    return false, "Missing http location information."
  end
  return false, "No update required."
end

local function updateFile(fileInfo)
  local needUpdate = updateCheck(fileInfo)
  if needUpdate then
    if fileInfo["file"] then
      local h = http.get(fileInfo.location)
      if h then
        local h2 = io.open(fileInfo.file, "w")
        if h2 then
          h2:write(h.readAll()):close()
          h.close()
          return true
        else
          h.close()
          error("Failed to open file for writing ("
                .. tostring(fileInfo.file) .. ")")
        end
      else
        error("Failed to open http handle ( "
              .. tostring(fileInfo.location) .. ") for file \""
              .. tostring(fileInfo.file) .. "\". (write)")
      end
    else
      error("Missing file location information.")
    end
  else
    return false, "No update required."
  end
end

local function updateAllFATS()
  print("Locating FAT files.")
  local FATS = fileSystem.getFATS()
  print("Done, found " .. tostring(#FATS) .. " total files.")
  for i = 1, #FATS do
    print("Updating:", FATS[i]["file"], "(", FATS[i]["version"], ")")
    local ok, err = updateFile(FATS[i])
    if not ok then
      printError(err)
    else
      print("Done, no errors.")
    end
  end
  print("Updated all files.")
end


if needLoad then
  return {
    updateFile = updateFile,
    updateCheck = updateCheck
  }
else
  return {
    updateAllFATS = updateAllFATS,
    updateFile = updateFile,
    updateCheck = updateCheck
  }
end
return {
  updateAllFATS = updateAllFATS,
  updateFile = updateFile,
  updateCheck = updateCheck
}
