--[[FATFILE
3
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/FatFileSystem.lua
]]

local funcs

-- Functions returned:

-- lists a directory into two tables, dirs and files
local function betterList(dir)
  local found = {}
  found.dirs = {}
  found.files = {}

  if fs.isDir(dir) then
    local ls = fs.list(dir)

    for i = 1,#ls do
      -- for each item in the directory..
      local f = dir .. "/" .. ls[i]
      if fs.isDir(f) then
        -- if directory, add to directories
        found.dirs[#found.dirs + 1] = f
      else
        -- if file, add to files
        found.files[#found.files + 1] = f
      end
    end
  end
  return found
end

-- scans the whole system for a file or directory,
-- from dir, with an ignore list.
-- does not use patterns.
local function betterFind(toFind, dir, isDirectory, ignore)
  assert(type(toFind) == "string",
      "betterFind: Bad argument 1: required string")
  assert(type(dir) == "string" or type(dir) == "nil",
      "betterFind: Bad argument 2: required string or nil")
  assert(type(isDirectory) == "boolean" or type(isDirectory) == "nil",
      "betterFind: Bad argument 3: required boolean or nil")
  assert(type(ignore) == "table" or type(ignore) == "nil",
      "betterFind: Bad argument 4: required table or nil")

  local function splitData(inp)
    for i = inp:len(), 1, -1 do
      -- from the end of the string, to the start
      if inp:sub(i,i) == "/" then
        -- if string[i] == "/"
        return inp:sub(i+1)
        -- return everything after the "/"
      end
    end
    return inp
    -- if nothing was found, assume the whole string is usable
  end

  dir = dir or ""
  ignore = ignore or {"/rom"}
  local found = {}

  local b = betterList(dir)
  -- get the directories and files in a directory

  if isDirectory then
    -- are we searching for a directory?
    for i = 1, #b.dirs do
      local d = b.dirs[i]
      if d == toFind then
        -- if this is the directory...
        found[#found + 1] = d
        -- add it to our list, and don't decend into it.
      else
        -- if this is not the directory we are looking for, decend into it.
        local flg = true
        for o = 1, #ignore do
          -- for each item in the ignore list
          if b.dirs[i] == ignore[o] then
            -- if this directory is ignored, skip it.
            flg = false
          end
        end

        if flg then
          -- if the directory is not ignored...
          local bf = betterFind(toFind, b.dirs[i])
          -- search this directory
          for o = 1, #bf do
            found[#found + 1] = bf[o]
            -- add each item found in the directory to our list (if any at all).
          end
        end
      end
    end
  else
    -- are we searching for a file?

    for i = 1, #b.dirs do
      -- for each directory in the current location...
      local flg = true
      for o = 1, #ignore do
        -- for each item in the ignore list
        if b.dirs[i] == ignore[o] then
          -- if this directory is ignored, skip it.
          flg = false
        end
      end

      if flg then
        -- if the directory is not ignored...
        local d = betterFind(toFind, b.dirs[i])
        -- search this directory
        for o = 1, #d do
          found[#found + 1] = d[o]
          -- add each item found in the directory to our list (if any at all).
        end
      end
    end

    for i = 1, #b.files do
      -- for each file found...
      local c = b.files[i]
      if splitData(c) == toFind then
        -- if the file is the one we are searching for, add it.
        found[#found + 1] = c
      end
    end
  end

  return found
end


-- gets all files marked by the special --[[FATFILE]] header
local function getFATS(dir)

  dir = dir or ""

  -- reads through a file to see if it contains a FATFILE header
  local function checkFiles(tab)
    local fats = {}
    for i = 1, #tab do
      local h = fs.open(tab[i],"r")
      if h then
        local ln = h.readLine()
        repeat
          if ln and type(ln) == "string" then
            -- if the file is empty, it will error without this.
            if ln:find("--[[FATFILE", 1, true) then
              fats[#fats + 1] = {
                file = tab[i],
                version = tonumber(h.readLine()),
                location = h.readLine()
              }
              break
            end
          end
          ln = h.readLine()
        until not ln
          -- read until at the end of the file.
        h.close()
      else
        printError("Failed to open file: " .. tostring(tab[i]))
      end
    end
    return fats
  end

  local exclude = {
    "/rom/"
  }

  local ls = betterList(dir)
  local found = checkFiles(ls.files)
  -- get files and directories in a nice orderly table
  -- then check for FATFILES

  for i = 1, #ls.dirs do
    -- for each directory...
    local flg = true
    for o = 1, #exclude do
      -- if the directory is excluded, don't check it.
      if ls.dirs[i] == exclude[o] then
        flg = false
      end
    end
    if flg then
      local b = getFATS(ls.dirs[i])
      for i = 1, #b do
        -- add each FAT returned to found.
        found[#found + 1] = b[i]
      end
    end
  end

  return found
end

funcs = {
  betterFind = betterFind,
  betterList = betterList,
  getFATS = getFATS
}

return funcs
